classdef ddpgCDPEA < BASEOPTIMIZER
% <2025> <learned> <multi> <real/integer/label/binary/permutation> <constrained/none>
    properties
        curProblem
        consNum
        Population1
        Population2
        alpha
        para
        NP
        hvValue
        currankNo
        curFrontNo
    end
    methods
        function init(Algorithm,Problem)
            Algorithm.curProblem = Problem;
            Algorithm.NP = Problem.N;
            Algorithm.hvValue = 0;
            
            %% Generate random population
            Algorithm.Population1 = Problem.Initialization(); 
            Algorithm.Population2 = Algorithm.Population1; 
            
            Algorithm.alpha       = 2./(1+exp(1).^(-Problem.FE*10/Problem.maxFE))-1;
            Algorithm.para        = ceil(Problem.maxFE/Problem.N)/2 - ceil(Problem.FE/Problem.N);

        end
        
        function [reward, nextState, done, bestPop]= update(baseOptimizer,action,Problem)
         %% Optimization
            % Re-rank
            baseOptimizer.Population1 = baseOptimizer.Population1(randperm(Problem.N));
            baseOptimizer.Population2 = baseOptimizer.Population2(randperm(Problem.N));
            Lia   = ismember(baseOptimizer.Population2.objs,baseOptimizer.Population1.objs, 'rows');
            gamma = 1-sum(Lia)/Problem.N;            
            [baseOptimizer.Population1,FrontNo1] = EnvironmentalSelection(baseOptimizer.Population1,Problem.N,baseOptimizer.alpha);
            [baseOptimizer.Population2,FrontNo2] = EnvironmentalSelection_noCon(baseOptimizer.Population2,Problem.N,baseOptimizer.alpha,gamma,baseOptimizer.para);

            % Offspring Reproduction
            Population_all   = [baseOptimizer.Population1,baseOptimizer.Population2];
            RankSolution_all = [FrontNo1,FrontNo2];
            MatingPool = TournamentSelection(2,2*Problem.N,RankSolution_all);
            Offspring  = OperatorGAhalf(Problem,Population_all(MatingPool));

            % Environmental Selection
            baseOptimizer.alpha = 2./(1+exp(1).^(-Problem.FE*10/Problem.maxFE)) - 1;
            baseOptimizer.para  = ceil(Problem.maxFE/Problem.N)/2 - ceil(Problem.FE/Problem.N);
            [baseOptimizer.Population1,~] = EnvironmentalSelection([baseOptimizer.Population1,Offspring],Problem.N,baseOptimizer.alpha);
            [baseOptimizer.Population2,~] = EnvironmentalSelection_noCon([baseOptimizer.Population2,Offspring],Problem.N,action,gamma,baseOptimizer.para);
            
            nextState = baseOptimizer.calState();
            nofinish = baseOptimizer.NotTerminated(baseOptimizer.Population1);
            done = ~nofinish;
            curHV = Problem.CalMetric('HV',baseOptimizer.Population1);
            if isnan(curHV)
                curHV = 0;
                reward = -1;
            elseif curHV - baseOptimizer.hvValue <=0
                reward = 0;
            else
                reward = 1;
            end
            baseOptimizer.hvValue = curHV;
            if done
                bestPop = baseOptimizer.Population1;
            else
                bestPop = 0;
            end
        end
        
        function state = calState(obj)
            % 识别可行点
            state = zeros(8,1);
            consSum = sum(obj.Population1.cons,2);
            objVec = obj.Population1.objs;
            feasible_mask = any(obj.Population1.cons<=0,2);
            if sum(feasible_mask)> 0
                feasible_points = obj.Population1(feasible_mask).decs;
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
    end
end