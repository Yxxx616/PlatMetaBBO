classdef BBOB_F4 < PROBLEM
% <2009> <single> <real> <expensive/none> <learned/none>
% Buche-Rastrigin function
% xopt --- 0 --- Optimal decision variables

%------------------------------- Reference --------------------------------
% N. Hansen, S. Finck, R. Ros, and A. Auger. Real-parameter black-box
% optimization benchmarking 2009: Noiseless functions definitions. RR-6829,
% INRIA. 2009.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2025 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    properties(Access = private)
        xopt;   % Optimal decision variables
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            obj.xopt = obj.ParameterSet(0);
            obj.M = 1;
            if isscalar(obj.xopt)
                if isempty(obj.D)
                    obj.D = 30;
                end
                obj.xopt = repmat(obj.xopt,1,obj.D);
            else
                obj.D = length(obj.xopt);
            end
            obj.lower    = zeros(1,obj.D) - 5;
            obj.upper    = zeros(1,obj.D) + 5;
            obj.encoding = ones(1,obj.D);
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,X)
            Z = Tosz(X-repmat(obj.xopt,size(X,1),1));
            S = 10.^(0.5*repmat(0:obj.D-1,size(X,1),1)/(obj.D-1));
            S(:,1:2:end) = 10.^(Z(:,1:2:end)>0).*S(:,1:2:end);
            Z = S.*Z;
            PopObj = 10*(obj.D-sum(cos(2*pi*Z),2)) + sum(Z.^2,2) + 100*fpen(X);
        end
    end
end

function X = Tosz(X)
    Xh       = zeros(size(X));
    Xh(X~=0) = log(abs(X(X~=0)));
    C1       = zeros(size(X)) + 5.5;
    C1(X>0)  = 10;
    C2       = zeros(size(X)) + 3.1;
    C2(X>0)  = 7.9;
    X = sign(X).*exp(Xh+0.049*(sin(C1.*Xh)+sin(C2.*Xh)));
end

function F = fpen(X)
    F = sum(max(0,abs(X)-5).^2,2);
end