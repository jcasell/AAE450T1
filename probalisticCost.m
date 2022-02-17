function [avgCost, stdCost] = probalisticCost(candaditateArchetexture)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: probablisticCost
%Description: Calculates the average and standard deviation of the cost for final design of spacecraft.
%Inputs: 
%   candidateArchitecture (Design of Mission from Morph Matrix)
%Outputs: 
%   avgCost - The average cost for the mission.
%   stdCost - The standard deviation of cost for the mission.

%Author: Brendan Jones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
comm =  candidateArchitecture.Communications;
prop =  candidateArchitecture.Propulsion;  
power = candidateArchitecture.Power;
inst =  candidateArchitecture.Instruments;
kick =  candidateArchitecture.Kick;

end