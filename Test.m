classdef Test < handle
    properties
        MetaOptimizer
        BaseOptimizer
        TestingSet
        env
    end
    methods
        function obj = Test(mo, bo, envConfig, problemset)
            obj.BaseOptimizer = bo();
            [~, obj.TestingSet] = splitProblemSet(problemset);
            obj.env = envConfig(obj.TestingSet,obj.BaseOptimizer,'test');
            fn = load(['AgentModel/', functions(mo).function, '_finalAgent.mat']);
            obj.MetaOptimizer = fn.agent;
        end
        
        function results = run(obj)
            simOpts = rlSimulationOptions('NumSimulations',length(obj.TestingSet)); %'MaxSteps',1000,...
            testingInfo = sim(obj.env,obj.MetaOptimizer,simOpts);
            bestPops = obj.env.getBestPops();
            results.testingInfo = testingInfo;
            results.bestPops = bestPops;
        end
    end
end