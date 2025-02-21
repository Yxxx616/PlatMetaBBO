classdef Train < handle
    properties
        MetaOptimizer
        BaseOptimizer
        TrainingSet
        epoch = 1
        env
    end
    methods
        function obj = Train(mo, bo, envName, problemset)
            obj.BaseOptimizer = bo();
            [obj.TrainingSet, ~] = splitProblemSet(problemset);
            obj.env = envName(obj.TrainingSet,obj.BaseOptimizer,'train');
            obsInfo = getObservationInfo(obj.env);
            actInfo = getActionInfo(obj.env);
            obj.MetaOptimizer = mo(obsInfo,actInfo);
        end
        
        function result = run(obj)
            trainOpts = rlTrainingOptions(...
                'MaxEpisodes',20000,...
                'MaxStepsPerEpisode',600,...
                'Plots','training-progress',...
                'StopTrainingCriteria',"AverageReward",...
                'StopTrainingValue',100,...
                'ScoreAveragingWindowLength',100,...
                'SaveAgentCriteria',"EpisodeReward",...
                'SaveAgentValue',85,...
                'SaveAgentDirectory','AgentModel');
            trainingInfo = train(obj.MetaOptimizer,obj.env,trainOpts);
            agent = obj.MetaOptimizer;
            save(trainOpts.SaveAgentDirectory + '/' + class(obj.MetaOptimizer) + '_finalAgent.mat','agent');
            result.trainingInfo = trainingInfo;
        end
    end
end