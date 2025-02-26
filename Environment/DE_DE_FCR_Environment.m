classdef DE_DE_FCR_Environment < rl.env.MATLABEnvironment
    %MYENVIRONMENT: Template for defining custom environment in MATLAB.    
    
    %% Properties (set properties' attributes accordingly)
    properties
        % Specify and initialize environment's necessary properties    
        curProblem
        baseoptimizer
        problemSet
        curPIdx
    end
    
    properties
        % Initialize system state [x,dx,theta,dtheta]'
        State = zeros(1,1)
    end
    
    properties(Access = protected)
        % Initialize internal flag to indicate episode termination
        IsDone = false        
    end
    methods              
        % Contructor method creates an instance of the environment
        % Change class name and constructor name accordingly
        function this = DE_DE_FCR_Environment(ps, bo, task)
            % Initialize Observation settings
            ObservationInfo = rlFiniteSetSpec([1:length(ps)]);
            ObservationInfo.Name = 'ProblemIdx';
            ObservationInfo.Description = 'F_';
            
            % Initialize Action settings    Continuous
            ActionInfo = rlNumericSpec([2 1],'LowerLimit', 0.5, 'UpperLimit', 1);
            ActionInfo.Name = 'Base-optimizer Parameters (Type and Range)';
            
            % The following line implements built-in functions of RL env
            this = this@rl.env.MATLABEnvironment(ObservationInfo,ActionInfo);
            this.problemSet = ps;
            this.baseoptimizer = bo;
            this.curPIdx = 1;
        end
        function InitialObservation = reset(this)
            if this.curPIdx > length(this.problemSet)
                this.curPIdx = 1;
            end
            this.curProblem = this.problemSet{this.curPIdx};
            this.baseoptimizer.Init(this.curProblem)
            InitialObservation = this.curPIdx;
            this.curProblemState = InitialObservation;
        end
       
        function [Observation,Reward,IsDone,LoggedSignals] = step(this, BOparameters)
            IsDone = false;
            if this.curPIdx > length(this.problemSet)
                IsDone = True;
            end
            LoggedSignals = [];
            for i = length(BOparameters)
                [r, Observation, ~, ~] = this.baseoptimizer.update(BOparameters(i), this.curProblem);
                Reward(i) = r;
            end
            this.IsDone = IsDone;
            this.curProblemState = this.curPIdx;
        end
    end
end
