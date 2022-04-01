%% Monte Carlo Run and Plot
clc
clear
close all

%Number of Iterations
n = 1000000;

%Results
costResults = [];

parfor p = 1:n
    cost = MonteCarloCost();
    if isreal(cost)
        costResults = [costResults cost];
    end
end

probplot(costResults)
