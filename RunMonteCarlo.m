%% Monte Carlo Run and Plot
clc
clear
close all

%Number of Iterations
n = 100000;

%Results
costResults = [];

parfor p = 1:n
    cost = MonteCarloCost();
    if isreal(cost)
        costResults = [costResults cost];
    end
end

sortedCost = sort(costResults)

ExpCost = median(costResults)
Conf70 = sortedCost(round(.7*length(costResults)))

marginExpCost = ExpCost*1.3
marginConf70 = Conf70*1.3

indexConf = min(find(sortedCost >= round(costResults(round(0.7*length(costResults)))/5)*5))

figure(1)
probplot(costResults)
xlabel('Cost, $ Millions (F2022)')

confidentData = sortedCost(1:indexConf-1);
exceededMargin = sortedCost((indexConf):end);

figure(2)
histogram(confidentData)
hold on
histogram(exceededMargin)
title('SHAC Monte Carlo Cost Distribution')
xlabel('Cost, $ Millions (F2022)')
ylabel('Monte Carlo Iterations')
legend('Data Within 70% Confidence Margin','Data Above 70% Confidence Margin')