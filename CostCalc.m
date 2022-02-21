function [Cost] = CostCalc(candidateArchitecture,m_spacecraft,m_prop)
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

%Assuming no non recurring costs for Prop, TTC, Power, Instruments, Kick

%Communication Network Cost
if comm == "DSN"
    costTTC = 11.6424*10^3;
elseif comm == "NSN"
    costTTC = 113.575/3.5*10^3;
elseif comm == "IDSN"
    costTTC = 120/3.5*10^3;
end

%Propulsion Cost
if prop == "Nuclear Thermal"
    costProp = 3000*10^3;
elseif prop == "OMS"
    costProp = 11.3*10^3;
elseif prop == "Solar Sail"
    costProp = 35*10^3;
elseif prop == "OMS"
    costProp = m_prop * 9.8472*10^-3;   % MMH + N2O4 https://yarchive.net/space/rocket/fuels/fuel_costs.html
elseif prop == "BHT-100"
    costProp =  5*10^2 + m_prop;   % $1000/kg Xenon estimated from https://trs.jpl.nasa.gov/bitstream/handle/2014/45452/08-2765_A1b.pdf?sequence=1
elseif prop == "BHT-600"        % Thruster costs estimated from above AIAA report
    costProp =  3*10^3 + m_prop;
else
    costProp = 0;
end

%Power Source Cost
%Instrument Power Calc
if inst == "Minimum"
    instPower = 302.6666667;
elseif inst == "Mid Level"
    instPower = 436;
elseif inst == "High Level"
    instPower = 596;
end
%Power Source Cost Calculation
if prop == "BHT-100"
    costPower = (instPower+75)*270*1.28;
elseif prop =="BHT-600"
    costPower = (instPower+300)*270*1.28;
else
    costPower = (instPower)*270*1.28;
end

if power == "Solar Panel/Nuclear"
    costPower = costPower + 8*1000;
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
switch candidateArchitecture.Kick 
    case "Star 48BV"
        costKick = 48*10^3;
    case "Centaur V"
        costKick = 72*10^3;
    case "Nuclear" 
        costKick = 378.26*10^3;
    case "Hybrid" 
        costKick = 81.66675143*10^3;
    case "Centaur V & Star 48BV"
        costKick = (48 + 72)*10^3;
    case "Centaur V & Nuclear" 
        costKick = (72 + 378.16)*10^3;
    case "Centaur V & Hybrid"
        costKick = (72 + 81.66675143)*10^3;
     case "Star 48BV & Hybrid"
        costKick = (48 + 81.66675143)*10^3;
    case "Star 48BV & Nuclear"
        costKick = (48 + 378.26)*10^3;
    case "Hybrid & Nuclear"
        costKick = (81.66675143 + 378.26)*10^3;
    otherwise 
        costKick = 0;
end

%SMAD Cost Calculations Includes Non-Recurring Developement and Single
%System Cost

%Spacecraft Bus if NO OTHER CER Used
optionalBusCostNRec = 1.29*(108*m_spacecraft);
optionalBusCostRec = 1.29*(283.5*(m_spacecraft^0.716));

%Structure and Thermal Control
% 6% of total mass using table A-2 SMAD
costThermNRec = 1.29*(646*(m_spacecraft*0.06)^0.684);
costThermRec = 1.29*(22.6*(m_spacecraft*0.06));

%Attitude Determination and Control System
% 6% of total mass using table A-2 SMAD
costAttNRec = 1.29*(324*(m_spacecraft*0.06));
costAttRec = 1.29*(795*(m_spacecraft*0.06)^0.593);

%Total Bus Cost SUM OF ABOVE
costBusRec = costThermRec+costAttRec+costPower+costProp;
costBusNRec = costThermNRec+costAttNRec;

%Communications Payload
% 7% of total mass using table A-2 SMAD
costCommNRec = 1.29*(618*(m_spacecraft*0.07));
costCommRec = 1.29*(189*(m_spacecraft*0.07));

%Space Vehicle Cost SUM OF ABOVE USE IN TOTAL WITH PROG AND OTHER
costVehRec = costBusRec+costCommRec+costInst;
costVehNRec = costBusNRec + costCommNRec;

%Integration Assembly and Test
costIntRec = 0.195*(costBusRec+costCommRec+costInst);
costIntNRec = 0.124*(costBusNRec+costCommNRec);


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
% opsCost = 1.29*5*(techCount*150+engCount*200) + 1.29*5*(techCount_cut*150+engCount_cut*200);

%Table 11-29 Ops Cost Estimate
%Keep Full Budget for first 5 years, cut 33 % for the last 30 years
opsCost = 1.29 * 5690 * 10;

total_Cost = (costVehRec+costVehNRec+costProgNRec+costProgRec+AGEcost+LOOScost+opsCost+costTTC+costIntRec+costIntNRec+costKick);

%Cost Vector
Cost = [costTTC, costProp, costPower, costInst,  costKick, costThermRec, costThermNRec, costAttRec, costAttNRec, costCommRec, costCommNRec, costIntRec, costIntNRec, costProgRec, costProgNRec, AGEcost, LOOScost, opsCost, total_Cost]/(1e3);


end
