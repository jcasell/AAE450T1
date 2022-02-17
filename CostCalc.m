function [Cost] = CostCalc(candidateArchitecture,m_spacecraft)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: CostCalc
%Description: Calculates cost of Morph Matrix components
%Inputs: candidateArchitecture (Design of Mission from Morph Matrix)
%Outputs: Cost (Millions F2022 Dollars Total Mission Cost),
%Reliability (Mission Reliability), ttHP(Time to Heliopause)
%Author: Charles Jansen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


comm =  candidateArchitecture.Communications;
prop =  candidateArchitecture.Propulsion;
power = candidateArchitecture.Power;
inst =  candidateArchitecture.Instruments;
kick =  candidateArchitecture.Kick;

%All Costs in Thousands

%Communication Network Cost
if comm == "DSN"
    costTTC = 133*10^3;
elseif comm == "NSN"
    costTTC = 113.575*10^3;
elseif comm == "IDSN"
    costTTC = 120*10^3;
end

%Propulsion Cost
if prop == "Nuclear Thermal"
    costProp = 3000*10^3;
elseif prop == "Chemical"
    costProp = 11.3*10^3;
elseif prop == "Solar Sail"
    costProp = 35*10^3;
elseif prop == "Plasma"
    costProp =  45*10^3;
else
    costProp = 0;
end

%Power Source Cost
if power == "RTG Nuclear"
    costPower = 100*10^3;
elseif power == "Solar Panel/Nuclear"
    costPower = 108*10^3;
else
    costPower = 0;
end

%Instrument Package Cost
if inst == "Minimum"
    costInst = 126.6*10^3;
elseif inst == "Mid Level"
    costInst = 178.11*10^3;
elseif inst == "High Level"
    costInst = 207.78*10^3;
end

%Kick Stage Cost
if kick == "Solid Motor"
    costKick = 13.046*10^3;
elseif kick == "Liquid"
    costKick = 38.73*10^3;
elseif kick == "Hybrid"
    costKick = 32.32*10^3;
else
    costKick = 0;
end

%SMAD Cost Calculations Includes Non-Recurring Developement and Single
%System Cost

%Spacecraft Bus if NO OTHER CER
%costBusNRec = 1.29*(108*m_spacecraft)
%costBusRec = 1.29*(283.5*(m_spacecraft^0.716));

%Structure and Thermal Control
% 6% of total mass using table A-2 SMAD
costThermNRec = 1.29*(646*(m_spacecraft*0.06)^0.684);
costThermRec = 1.29*(22.5*(m_spacecraft*0.06));

%Attitude Determination and Control System
% 6% of total mass using table A-2 SMAD
costAttNRec = 1.29*(324*(m_spacecraft*0.06));
costAttRec = 1.29*(795*(m_spacecraft*0.06)^0.593);

%Total Bus Cost SUM OF ABOVE
costBusRec = costThermRec+costAttRec+costPower+costKick;
costBusNRec = costThermNRec+costAttNRec;

%Communications Payload
% 7% of total mass using table A-2 SMAD
costCommNRec = 1.29*(618*(m_spacecraft*0.07));
costCommRec = 1.29*(189*(m_spacecraft*0.07));

%Integration Assembly and Test
costIntRec = 0.195*(costBusRec+costCommRec+costInst);
costIntNRec = 0.124*(costBusNRec+costCommNRec);

%Space Vehicle Cost SUM OF ABOVE USE IN TOTAL WITH PROG AND OTHER
costVehRec = costBusRec+costCommRec+costInst;
costVehNRec = costBusNRec + costCommNRec;

%Prog Lev Cost
costProgNRec = 0.357*(costVehNRec+costIntNRec);
costProgRec = 0.320*(costVehRec+costIntRec);

%Other Costs
AGEcost = 1.29*(0.432*(costBusNRec/1.29)^0.907+2.244);

LOOScost = 1.29*5850;

%Ops Cost
%Table 11-25 Ops Cost Estimate
%Keep full team for first 5 years, cut extra staff for last 30 years
% techCount = 6;
% engCount = 34-6;
% engCount_cut = engCount - 10;
% techCount_cut = techCount - 2;
% opsCost = 1.29*5*(techCount*150+engCount*200) + 1.29*30*(techCount_cut*150+engCount_cut*200);

%Table 11-29 Ops Cost Estimate
%Keep Full Budget for first 5 years, cut 33 % for the last 30 years
opsCost = 1.29 * 5690 * 5 + 1.29*((2/3)*5690*30);

total_Cost = (10^-3)*(costVehRec+costVehNRec+costProgNRec+costProgRec+AGEcost+LOOScost+opsCost+costTTC+costIntRec+costIntNRec + costProp);

%Cost Vector
Cost = [costTTC / (1E3), costProp / (1E3), costPower / (1E3), costInst / (1E3),  costKick / (1E3), costThermRec / (1E3), costThermNRec / (1E3), costAttRec / (1E3), costAttNRec / (1E3), costCommRec / (1E3), costCommNRec / (1E3), costIntRec / (1E3), costIntNRec / (1E3), costProgRec / (1E3), costProgNRec / (1E3), AGEcost / (1E3), LOOScost / (1E3), opsCost / (1E3), total_Cost];


end