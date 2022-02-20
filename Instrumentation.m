function [Science, Cost, Mass, Power] = Instrumentation(candidateArchitecture)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: MissionCalc
%Description: Calculaes results of a given candidate arcitecture mission.
%Inputs: candidateArchitecture (Design of Mission from Morph Matrix)
%Outputs: Science (Science Value), Cost (F2022 Dollars Total Mission Cost),
%Reliability (Mission Reliability), ttHP(Time to Heliopause)
%Author: Jeremy Casella
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

package = candidateArchitecture.Instruments;

if package == "Minimum";
    Science = [0.7841 0.8184 0.7315 0 0];   %Science for each phase of mission
    Cost = 126.6;   %Millions of Dollars in 2022 dollars
    Mass = 30.5; %mass kg
    Power = 45.4;   %Power W
elseif package == "Mid Level";
    Science = [0.9620 0.9184 0.9630 1 0];   %Science for each phase of mission
    Cost = 178.11;   %Millions of Dollars in 2022 dollars
    Mass = 52.5; %mass kg
    Power = 65.4;   %Power W
elseif package == "High Level";
    Science = [1 1 1 1 1];   %Science for each phase of mission
    Cost = 207.78;   %Millions of Dollars in 2022 dollars
    Mass = 75; %mass kg
    Power = 89.4;   %Power W
else
    Science = 0;
    Cost = 0;
    Mass= 0;
    Power = 0;
end