classdef DE_DE_FCR_Metaoptimizer < rl.agent.CustomAgent
    % MetaOptimizerRL 基于强化学习的元优化器模板类
    % 继承自rl.agent.CustomAgent，实现必要接口
    
    properties
        metaPopulation
        metaNP = 50
        metaTable 
        problemSet
        
        ExperienceBuffer = struct(...
            'Observations', {}, ...
            'Actions', {}, ...
            'Rewards', {}, ...
            'NextObservations', {}, ...
            'IsDone', {})
    end
    
    methods
        function obj = DE_DE_FCR_Metaoptimizer(observationInfo, actionInfo)
            obj = obj@rl.agent.CustomAgent();
            obj.metaTable = containers.Map('KeyType', 'char', 'ValueType', 'any');
            obj.metaPopulation = rand(obj.metaNP, actionInfo.Dimension(1));
            for i = 1:length(observationInfo.Elements)
                obj.metaTable(num2str(i))=obj.metaPopulation;
            end
            obj.ObservationInfo = observationInfo;
            obj.ActionInfo = actionInfo;
        end
    end
    methods (Access = protected)
        function action = getActionImpl(obj,observation)
            obsKey = class(obj.problemSet{observation});
            % 检查 observationStr 是否是 metaTable 的一个键
            if isKey(obj.metaTable, obsKey)
                % 如果键存在，获取对应的值
                action = obj.metaTable(obsKey).population;
            else
                action = repmat(rand(2,1),obj.metaNP,1);
            end
            action = saturate(this.ActionInfo,action);
            action = max(min(action, obj.ActionInfo.UpperLimit), ...
                        obj.ActionInfo.LowerLimit);
        end
        function action = getActionWithExplorationImpl(obj, observation)
            obsKey = class(obj.problemSet{observation});
            % 检查 observationStr 是否是 metaTable 的一个键
            if isKey(obj.metaTable, obsKey)
                % 如果键存在，获取对应的值
                action = obj.metaTable(obsKey).population;
            else
                action = repmat(rand(2,1),obj.metaNP,1);
            end
            Site = rand(size(action)) < 0.8;
            Offspring = action;
            Parent2 = action(randperm(length(action)));
            Parent3 = action(randperm(length(action)));
            Offspring(Site) = Offspring(Site) + F*(Parent2(Site)-Parent3(Site));
            % 确保动作在有效范围内
            action = Offspring;
            action = saturate(this.ActionInfo,action);
            action = max(min(action, obj.ActionInfo.UpperLimit), ...
                        obj.ActionInfo.LowerLimit);
        end
        function learnImpl(obj, experience)
            x = experience{1}{1};
            u = experience{2}{1};
            dx = experience{4}{1};  
            allKeys = keys(obj.metaTable); % 获取所有键

        end
        
        function resetImpl(obj)
            % 重置智能体状态
            % 初始化或重置内部状态变量
            obj.ExperienceBuffer = [];
        end
    end
end
