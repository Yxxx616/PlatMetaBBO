classdef ppoDMOEAeC < BASEOPTIMIZER
% <2017> <multi> <real/integer/label/binary/permutation>
% Decomposition-based multi-objective evolutionary algorithm with the
% e-constraint framework
% INm --- 0.2 --- Iteration interval of alternating the main objective function

%------------------------------- Reference --------------------------------
% J. Chen, J. Li, and B. Xin, DMOEA-eC: Decomposition-based multiobjective
% evolutionary algorithm with the e-constraint framework, IEEE Transactions
% on Evolutionary Computation, 2017, 21(5): 714-730.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2024 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------
    properties
        curProblem
        consNum
        Population
        NP
        hvValue
        currankNo
        curFrontNo
        
        N
        INm
        Archive
        W
        T
        nr
        B
        z
        znad
    end
    methods
        function init(Algorithm,Problem)
            Algorithm.curProblem = Problem;
            Algorithm.NP = Problem.N;
            Algorithm.hvValue = 0;
            
            %% Parameter setting
            Algorithm.INm = Algorithm.ParameterSet(0.2);

            %% Generate the weight vectors
            [Algorithm.W,Algorithm.N] = UniformPoint(Problem.N,Problem.M-1,'grid');
            % Size of neighborhood
            Algorithm.T = ceil(Algorithm.N/10);
            % Maximum number of solutions replaced by each offspring
            Algorithm.nr = ceil(Algorithm.N/100);

            %% Detect the neighbours of each solution
            Algorithm.B = pdist2(Algorithm.W,Algorithm.W);
            [~,Algorithm.B] = sort(Algorithm.B,2);
            Algorithm.B = Algorithm.B(:,1:Algorithm.T);

            %% Generate random population
            Algorithm.Population     = Problem.Initialization(Algorithm.N);
            [Algorithm.Archive,Algorithm.znad] = UpdateArchive(Algorithm.Population,Problem.N);
            Algorithm.z  = min(Algorithm.Population.objs,[],1);
            Algorithm.Pi = ones(Algorithm.N,1);

       end
        

        function [reward, nextState, done]= update(Algorithm,action,Problem)
            Algorithm.INm = action;
            if ~mod(gen,ceil(Algorithm.INm*Problem.maxFE/Algorithm.N))
               % Solution-to-subproblem matching
               s = randi(Problem.M);
               S = 1 : Algorithm.N;
               while ~isempty(S)
                   PopObj = (Algorithm.Population(S).objs-repmat(Algorithm.z,length(S),1))./repmat(Algorithm.znad-Algorithm.z,length(S),1);
                   l      = randi(length(S));
                   [~,k]  = min(sum(abs(PopObj(:,[1:s-1,s+1:end])-repmat(Algorithm.W(S(l),:),length(S),1)),2));
                   temp             = Algorithm.Population(S(l));
                   Algorithm.Population(S(l)) = Algorithm.Population(S(k));
                   Algorithm.Population(S(k)) = temp;
                   S(l) = [];
               end
               PopObj = Algorithm.Population.objs;
               oldObj = PopObj(:,s) + 1e-6*sum(PopObj(:,[1:s-1,s+1:end]),2);
            end
            if ~mod(gen,10)
                % Allocation of computing resources
                PopObj    = Algorithm.Population.objs;
                newObj    = PopObj(:,s) + 1e-6*sum(PopObj(:,[1:s-1,s+1:end]),2);
                DELTA     = (oldObj-newObj)./oldObj;
                Temp      = DELTA <= 0.001;
                Pi(~Temp) = 1;
                Pi(Temp)  = (0.95+0.05*DELTA(Temp)/0.001).*Pi(Temp);
                oldObj    = newObj;
            end
            for subgeneration = 1 : 5
                % Choose I
                Bounday = find(sum(Algorithm.W==1,2)==1&sum(Algorithm.W<1e-3,2)==size(Algorithm.W,2)-1)';
                I = [Bounday,TournamentSelection(10,floor(Algorithm.N/5)-length(Bounday),-Pi)];

                % Evolve each solution in I
                Offspring(1:length(I)) = SOLUTION();
                for i = 1 : length(I)
                    % Choose the parents
                    if rand < 0.9
                        P = Algorithm.B(I(i),randperm(size(Algorithm.B,2)));
                    else
                        P = randperm(Algorithm.N);
                    end

                    % Generate an offspring
                    Offspring(i) = OperatorGAhalf(Problem,Algorithm.Population(P(1:2)));

                    % Update the ideal point
                    Algorithm.z = min(Algorithm.z,Offspring(i).obj);

                    % Subproblem-to-solution matching
                    OObj      = (Offspring(i).obj-Algorithm.z)./(Algorithm.znad-Algorithm.z);
                    CV        = sum(max(0,repmat(OObj([1:s-1,s+1:end]),Algorithm.N,1)-Algorithm.W),2);
                    CV(CV==0) = 1./sum(repmat(OObj([1:s-1,s+1:end]),sum(CV==0),1)-Algorithm.W(CV==0,:),2);
                    [~,k]     = min(CV);
                    P         = Algorithm.B(k,randperm(size(Algorithm.B,2)));

                    % Update the solutions
                    PObj   = Algorithm.Population(P).objs;
                    OObj   = repmat(Offspring(i).obj,length(P),1);
                    FmainP = PObj(:,s) + 1e-6*sum(PObj(:,[1:s-1,s+1:end]),2);
                    FmainO = OObj(:,s) + 1e-6*sum(OObj(:,[1:s-1,s+1:end]),2);
                    PObj   = (PObj-repmat(Algorithm.z,length(P),1))./repmat(Algorithm.znad-Algorithm.z,length(P),1);
                    OObj   = (OObj-repmat(Algorithm.z,length(P),1))./repmat(Algorithm.znad-Algorithm.z,length(P),1);
                    CVP    = sum(max(0,PObj(:,[1:s-1,s+1:end])-Algorithm.W(P,:)),2);
                    CVO    = sum(max(0,OObj(:,[1:s-1,s+1:end])-Algorithm.W(P,:)),2);
                    Algorithm.Population(P(find(CVO==0&CVP==0&FmainO<FmainP|CVO<CVP,Algorithm.nr))) = Offspring(i);
                end

                % Update the archive
                [Algorithm.Archive,Algorithm.znad] = UpdateArchive([Algorithm.Archive,Offspring],Problem.N);
            end
            
            nextState = Algorithm.calState();
            nofinish = Algorithm.NotTerminated(Algorithm.Archive);
            done = ~nofinish;
            curHV = Problem.CalMetric('HV',Algorithm.Population);
            if isnan(curHV)
                curHV = 0;
                reward = -1;
            elseif curHV - Algorithm.hvValue <=0
                reward = 0;
            else
                reward = 1;
            end
            Algorithm.hvValue = curHV;
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
    end
end