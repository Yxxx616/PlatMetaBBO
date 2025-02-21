classdef ppoMOEAD2WA < BASEOPTIMIZER
    properties
        curProblem
        consNum
        Population
        NP
        hvValue
        currankNo
        curFrontNo
        
        OrN
        W
        N
        Tnr
        B
        T
        nr
        Z
        initialE
        nCon
        CV
        
    end
    methods
        function init(Algorithm, Problem)
            
            Algorithm.curProblem = Problem;
            Algorithm.NP = Problem.N;
            Algorithm.hvValue = 0;
            
            %% Generate the weight vectors
            Algorithm.OrN            = Problem.N;
            [Algorithm.W, Problem.N] = WeightGeneration(Problem.N, Problem.N, Problem.M, 1.0);

            %% Detect the neighbours of each solution
            Algorithm.T      = 20;
            Algorithm.nr     = 2;
            Algorithm.B      = pdist2(Algorithm.W, Algorithm.W);
            [~, Algorithm.B] = sort(Algorithm.B, 2);
            Algorithm.B      = Algorithm.B(:, 1:Algorithm.T);
            
            %% Generate random population
            Algorithm.Population    = Problem.Initialization();
            Algorithm.Z             = min(Algorithm.Population.objs, [], 1);
            [Algorithm.initialE, ~] = max(max(0, Algorithm.Population.cons), [], 1);
            Algorithm.initialE(Algorithm.initialE < 1) = 1;
            Algorithm.nCon          = size(Algorithm.Population.cons, 2);
            Algorithm.CV            = min(sum(max(0, Algorithm.Population.cons)./Algorithm.initialE, 2)./Algorithm.nCon, [], 1);
            Algorithm.Z             = [Algorithm.Z,Algorithm.CV]; 
        end
        
        function [reward, nextState, done]= update(baseOptimizer,action,Problem)
            %% Optimization
            
            % Reduce the dynamic constraint boundry
            epsn = repmat(max(0,action), 1, baseOptimizer.nCon);

            % Update weights
            a    = (baseOptimizer.W(:, Problem.M + 1) - 1e-6) > epsn(:, 1)./baseOptimizer.initialE(:, 1);
            baseOptimizer.W(a, :) = [];

            % Update population
            if Problem.N > size(baseOptimizer.W, 1)
                Problem.N  = size(baseOptimizer.W, 1);
                baseOptimizer.B          = pdist2(baseOptimizer.W, baseOptimizer.W);
                [~, baseOptimizer.B]     = sort(baseOptimizer.B, 2);
                baseOptimizer.B          = baseOptimizer.B(:, 1:baseOptimizer.T);
                baseOptimizer.Population = PopulationUpdate(baseOptimizer.Population, Problem.N, baseOptimizer.initialE, epsn, baseOptimizer.Z(:, 1:Problem.M));
            end
            % For each solution
            for i = 1 : Problem.N     
                % Choose the parents
                if rand < 0.9
                    P = baseOptimizer.B(i,randperm(size(baseOptimizer.B, 2)));
                else
                    P = randperm(Problem.N);
                end

                % Generate an offspring
                Offspring = OperatorGAhalf(Problem,baseOptimizer.Population(P(1:2)));

                % Update the ideal point
                baseOptimizer.Z(:, 1:Problem.M)   = min(baseOptimizer.Z(:, 1:Problem.M), Offspring.obj);
                baseOptimizer.CV                  = min(sum(max(0, Offspring.cons)./baseOptimizer.initialE, 2)./baseOptimizer.nCon, [], 1);
                baseOptimizer.Z(:, Problem.M + 1) = min(baseOptimizer.Z(:, Problem.M + 1), baseOptimizer.CV);

                % Calculate the constraint violation of offspring and P
                cvo = max(0, Offspring.con);
                cvp = max(0, baseOptimizer.Population(P).cons); 
                cvO = sum(max(0, Offspring.cons)./baseOptimizer.initialE, 2)./baseOptimizer.nCon;
                cvP = sum(max(0, baseOptimizer.Population(P).cons)./baseOptimizer.initialE, 2)./baseOptimizer.nCon;

                % Update the solutions in P by PBI approach
                PObj    = [baseOptimizer.Population(P).objs, cvP];
                OObj    = [Offspring.obj, cvO];
                normW   = sqrt(sum(baseOptimizer.W(P, :).^2, 2));
                normP   = sqrt(sum((PObj - repmat(baseOptimizer.Z, length(P), 1)).^2, 2));
                normO   = sqrt(sum((OObj - baseOptimizer.Z).^2, 2));
                CosineP = sum((PObj - repmat(baseOptimizer.Z, length(P), 1)).*baseOptimizer.W(P, :),2)./normW./normP;
                CosineO = sum(repmat(OObj - baseOptimizer.Z,length(P), 1).*baseOptimizer.W(P, :),2)./normW./normO;
                g_old   = normP.*CosineP + 5*normP.*sqrt(1 - CosineP.^2);
                g_new   = normO.*CosineO + 5*normO.*sqrt(1 - CosineO.^2);
                % Neighbor solution replacement
                index   = find((sum(cvo<=epsn, 2)==baseOptimizer.nCon&sum(cvp<=epsn, 2)==baseOptimizer.nCon&g_old>=g_new)|(sum(cvo<=epsn, 2)==baseOptimizer.nCon&sum(cvp<=epsn, 2)<baseOptimizer.nCon)|(sum(cvo<=epsn,2)<baseOptimizer.nCon&sum(cvp<=epsn, 2)<baseOptimizer.nCon&sum(max(0, baseOptimizer.Population(P).cons), 2)>sum(max(0, Offspring.con))), baseOptimizer.nr);
                baseOptimizer.Population(P(index)) = Offspring;
                  
            end  
            nextState = calState(baseOptimizer);
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



function epsn = ReduceBoundary(eF, k, MaxK)
% The shrink of the dynamic constraint boundary  
    cp       = 4;
    z        = 1e-8;
    Nearzero = 1e-15;
    B        = MaxK./power(log((eF + z)./z), 1.0./cp);
    B(B==0)  = B(B==0) + Nearzero;
    f        = eF.* exp( -(k./B).^cp );
    tmp      = find(abs(f-z) < Nearzero);
    f(tmp)   = f(tmp).*0 + z;
    epsn     = f - z;
    epsn(epsn<=0) = 0;
end