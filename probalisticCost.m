function [avgCost, stdCost] = probalisticCost(candaditateArchetexture, cost_vec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: probablisticCost
%Description: Calculates the average and standard deviation of the cost for final design of spacecraft.
%Inputs: 
%   candidateArchitecture (Design of Mission from Morph Matrix)
%   cost_vec - Vector of all the costs involved in final spacecraft cost. 
%Outputs: 
%   avgCost - The average cost for the mission.
%   stdCost - The vector standard deviations of cost for each element of
%   spacecraft.

%Author: Brendan Jones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Import Costs of Each Element
costTTC = cost_vec(1);
costProp = cost_vec(2);
costPower = cost_vec(3);
costInst = cost_vec(4);
costKick = cost_vec(5);
costThermRec = cost_vec(6);
costThermNRec = cost_vec(7);
costAttRec = cost_vec(8);
costAttNRec = cost_vec(9);
costCommRec = cost_vec(10);
costCommNRec = cost_vec(11);
costIntRec = cost_vec(12);
costIntNRec = cost_vec(13);
costProgRec = cost_vec(14);
costProgNRec = cost_vec(15);
AGEcost = cost_vec(16);
LOOScost = cost_vec(17);
opsCost = cost_vec(18);

%Find SEE of each element
SEE_TTC = 0.2; %dummy value
SEE_Prop = (310 / 1E6) / costProp; %SMAD, check
SEE_Power =0.2;%dummy value
SEE_Inst = 0.29; %ask about equation used later , SMAD
SEE_Kick = 0.22; %SMAD
SEE_ThermRec = 0.21; %SMAD
SEE_ThermNRec = 0.22; %SMAD
SEE_AttRec = 0.36; %SMAD
SEE_AttNRec = 0.44; %SMAD
SEE_CommRec = 0.39; %SMAD
SEE_CommNRec = 0.38; %SMAD
SEE_IntRec = 0.34; %SMAD
SEE_IntNRec = 0.42; %SMAD
SEE_ProgRec = 0.4; %SMAD
SEE_ProgNRec = 0.5; %SMAD
SEE_AGE = 0.37; %SMAD
SEE_LOOS = 0.2; %dummy value
SEE_ops = 0; %dummy value


avgCost = cost_vec(end);
stdCost = [SEE_TTC, SEE_Prop, SEE_Power, SEE_Inst, SEE_Kick, SEE_ThermRec, SEE_ThermNRec, SEE_AttRec, SEE_AttNRec, SEE_CommRec, SEE_CommNRec, SEE_IntRec,  SEE_IntNRec, SEE_ProgRec, SEE_ProgNRec, SEE_AGE, SEE_LOOS, SEE_ops];
end