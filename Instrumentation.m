function [Science, Cost, Mass] = Instrumentation(package)

if package = 1;
    Science = [0.7841 0.8184 0.7315];   %Science for each phase of mission
    Cost = 126.6;   %Millions of Dollars in 2022 dollars
    Mass = 40.5; %mass kg
elseif package = 2;
    Science = [0.9620 0.9184 0.9630];   %Science for each phase of mission
    Cost = 178.11;   %Millions of Dollars in 2022 dollars
    Mass = 62.5; %mass kg
elseif package = 3;
    Science = [1 1 1];   %Science for each phase of mission
    Cost = 207.78;   %Millions of Dollars in 2022 dollars
    Mass = 75; %mass kg
else
    Science = 0;
    Cost = 0;
    Mass= 0;
end