classdef ppoCMOEAD < BASEOPTIMIZER
%------------------------------- Reference --------------------------------
% H. Jain and K. Deb, An evolutionary many-objective optimization algorithm
% using reference-point based non-dominated sorting approach, part II:
% Handling constraints and extending to an adaptive approach, IEEE
% Transactions on Evolutionary Computation, 2014, 18(4): 602-622.
    properties
        curProblem
        Population
        NP
        hvValue
        currankNo
        curFrontNo
        Z
        W
        T
        nr
        B
    end
    methods
        function init(Algorithm,Problem)
            Algorithm.curProblem = Problem;
            Algorithm.Population = Problem.Initialization();
            Algorithm.Z = min(Algorithm.Population.objs,[],1);
            
            Algorithm.NP = Problem.N;
            Algorithm.hvValue = 0;
            
            %% Generate the weight vectors
            [Algorithm.W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Algorithm.T  = ceil(Problem.N/10);
            Algorithm.nr = ceil(Problem.N/100);

            %% Detect the neighbours of each solution
            Algorithm.B = pdist2(Algorithm.W,Algorithm.W);
            [~,Algorithm.B] = sort(Algorithm.B,2);
            Algorithm.B = Algorithm.B(:,1:Algorithm.T);
        end
          
       function state = calState(obj)
        % 识别可行点
        state = zeros(8,1);
        consSum = sum(obj.Population.cons,2);
        objVec = obj.Population.objs;
        feasible_mask = any(obj.Population.cons<=0,2);
        if sum(feasible_mask)> 0
            feasible_points = obj.Population(feasible_mask).decs;
            % 使用DBSCAN聚类算法识别可行组件
            epsilon = 0.5; % 邻域半径，需要根据数据调整
            minpts = 10; % 邻域内最小点数，需要根据数据调整
            [idx, ~] = dbscan(feasible_points, epsilon, minpts);

            % 计算可行组件数量
            NF = numel(unique(idx)) - 1; % 减1是因为0是为噪声点分配的
            state(1) = NF;
            % 计算可行性比率
            qF = sum(feasible_mask) / obj.NP;
            state(2) = qF;

            % 计算可行边界交叉比率
            % 计算边界交叉数量
            crossings = sum(diff([0, feasible_mask', 0]) ~= 0);
            RFBx = crossings / (obj.NP - 1);
            state(3) = RFBx;
        end

        % 计算信息内容特征
        % 首先，你需要对约束违反值进行排序
        cons_sorted = sort(consSum);
        H = zeros(obj.NP,1);
        probabilities = hist(cons_sorted, unique(cons_sorted)) / obj.NP;
        for i = 1:length(probabilities)
            p = probabilities(i);
            if p > 0
                H(i) =  - p * log(p);
            end
        end

        % 计算信息内容的最大值（Hmax）
        Hmax = max(H);
        state(4) = Hmax;


        FVC1 = corr(objVec(:,1), consSum, 'Type', 'Spearman');
        FVC2 = corr(objVec(:,2), consSum, 'Type', 'Spearman');
        state(5) = FVC1;
        state(6) = FVC2;

        minFitness = min(objVec, [], 1);
        maxFitness = max(objVec, [], 1);

        % 计算约束违反程度的最小值和最大值
        minViolation = min(consSum);
        maxViolation = max(consSum);

        % 确定理想区域的范围
        % 对于每个目标，理想区域的范围是目标最小值加上25%的目标范围
        % 对于约束违反程度，理想区域的范围是约束最小值加上25%的约束范围
        idealZoneFitness = minFitness + 0.25 * (maxFitness - minFitness);
        idealZoneViolation = minViolation + 0.25 * (maxViolation - minViolation);

        % 计算在理想区域内的点的数量
        inIdealZone = sum(all(objVec <= idealZoneFitness, 2) & consSum <= idealZoneViolation);

        % 计算理想区域比例
        PiIZ0_25 = inIdealZone / obj.NP;

        % 对于 1% 的理想区域，可以类似地计算
        idealZoneFitness = minFitness + 0.01 * (maxFitness - minFitness);
        idealZoneViolation = minViolation + 0.01 * (maxViolation - minViolation);
        inIdealZone = sum(all(objVec <= idealZoneFitness, 2) & consSum <= idealZoneViolation);
        PiIZ0_01 = inIdealZone / obj.NP;

        state(7) = PiIZ0_25;
        state(8) = PiIZ0_01;
       end
        
       function [reward, nextState, done]= update(baseOptimizer,action,Problem)
           % For each solution
            for i = 1 : Problem.N      
                % Choose the parents
                if rand < 0.9
                    P = baseOptimizer.B(i,randperm(size(baseOptimizer.B,2)));
                else
                    P = randperm(Problem.N);
                end

                % Generate an offspring
                Offspring = OperatorGAhalf(Problem,baseOptimizer.Population(P(1:2)));

                % Update the ideal point
                baseOptimizer.Z = min(baseOptimizer.Z,Offspring.obj);

                % Calculate the constraint violation of offspring and P
                CVO = sum(max(0,Offspring.con));
                CVP = sum(max(0,baseOptimizer.Population(P).cons),2);

                % Update the solutions in P by PBI approach
                normW   = sqrt(sum(baseOptimizer.W(P,:).^2,2));
                normP   = sqrt(sum((baseOptimizer.Population(P).objs-repmat(baseOptimizer.Z,length(P),1)).^2,2));
                normO   = sqrt(sum((Offspring.obj-baseOptimizer.Z).^2,2));
                CosineP = sum((baseOptimizer.Population(P).objs-repmat(baseOptimizer.Z,length(P),1)).*baseOptimizer.W(P,:),2)./normW./normP;
                CosineO = sum(repmat(Offspring.obj-baseOptimizer.Z,length(P),1).*baseOptimizer.W(P,:),2)./normW./normO;
                g_old   = normP.*CosineP + action*normP.*sqrt(1-CosineP.^2);
                g_new   = normO.*CosineO + action*normO.*sqrt(1-CosineO.^2);
                baseOptimizer.Population(P(find(g_old>=g_new & CVP==CVO | CVP>CVO,baseOptimizer.nr))) = Offspring;
            end
            nextState = baseOptimizer.calState();
            nofinish = baseOptimizer.NotTerminated(baseOptimizer.Population);
            done = ~nofinish;
            curHV = Problem.CalMetric('HV',baseOptimizer.Population);
            if isnan(curHV)
                curHV = 0;
                reward = -1;
            elseif curHV - baseOptimizer.hvValue <=0
                reward = 0;
            else
                reward = 1;
            end
            baseOptimizer.hvValue = curHV;
       end
    end
end