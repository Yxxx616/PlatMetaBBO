function [trainingSet,testingSet] = splitProblemSet(problemset)
%SPLITPROBLEMSET 此处显示有关此函数的摘要
if strcmp(problemset,'LIRCMOP')
    for i = 1:14
        if i <= 10
            trainingSet{i} = eval(sprintf('LIRCMOP%d', i));
        else
            testingSet{i-10} = eval(sprintf('LIRCMOP%d', i));
        end
    end
elseif strcmp(problemset,'BBOB')
    testList = [1,5,6,10,15,20];
    count1 = 1;
    count2 = 1;
    for i = 1:24  
        if ismember(i, testList)
            testingSet{count1} = eval(sprintf('BBOB_F%d', i));
            count1 = count1 + 1;
        else
            trainingSet{count2} = eval(sprintf('BBOB_F%d', i));
            count2 = count2 + 1;
        end
    end
elseif strcmp(problemset,'CF')
    for i = 1:10
        if i <= 8
            trainingSet{i} = eval(sprintf('CF%d', i));
        else
            testingSet{i-8} = eval(sprintf('CF%d', i));
        end
    end
elseif strcmp(problemset,'MW')
    for i = 1:14
        if i <= 10
            trainingSet{i} = eval(sprintf('MW%d', i));
        else
            testingSet{i-10} = eval(sprintf('MW%d', i));
        end
    end
elseif strcmp(problemset,'CEC2017')
    for i = 1:28
        if i <= 21
            trainingSet{i} = eval(sprintf('CEC2017_F%d', i));
        else
            testingSet{i-21} = eval(sprintf('CEC2017_F%d', i));
        end
    end
else
    trainingSet{1} = problemset;
    testingSet{1} = problemset;
end
        
end

