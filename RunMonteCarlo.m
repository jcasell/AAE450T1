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

ExpectedCost = mean(costResults)

figure(1)
probplot(costResults)
xlabel('Cost, $ Millions (F2022)')

figure(2)
histogram(costResults)
title('SHAC Monte Carlo Cost Distribution')
xlabel('Cost, $ Millions (F2022)')
ylabel('Monte Carlo Iterations')