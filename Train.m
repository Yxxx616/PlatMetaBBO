classdef Train < handle
    properties
        MetaOptimizer
        BaseOptimizer
        TrainingSet
        TrainingSetName
        epoch = 1
        env
    end
    methods
        function obj = Train(mo, bo, envName, problemsetName)
            obj.BaseOptimizer = bo();
            obj.TrainingSetName = problemsetName;
            [obj.TrainingSet, ~] = splitProblemSet(problemsetName);
            obj.env = envName(obj.TrainingSet,obj.BaseOptimizer,'train');
            obsInfo = getObservationInfo(obj.env);
            actInfo = getActionInfo(obj.env);
            obj.MetaOptimizer = mo(obsInfo,actInfo);
        end
        
        function result = run(obj)
            trainOpts = rlTrainingOptions(...
                'MaxEpisodes',10000,...
                'MaxStepsPerEpisode',600,...
                'Plots','training-progress',...
                'StopTrainingCriteria',"AverageReward",...
                'StopTrainingValue',100,...
                'ScoreAveragingWindowLength',100,...
                'SaveAgentCriteria',"EpisodeReward",...
                'SaveAgentValue',85,...
                'SaveAgentDirectory','AgentModel/TrainingAgentLog');
            trainingInfo = train(obj.MetaOptimizer,obj.env,trainOpts);
            agent = obj.MetaOptimizer;
            save( 'AgentModel/' + class(obj.MetaOptimizer) + '_finalAgent.mat','agent');
            result.trainingInfo = trainingInfo;
        end
    end
end