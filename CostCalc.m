function [Cost] = CostCalc(candidateArchitecture)
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

Cost = 0;

%Communication Network Cost
if comm == "DSN"
    Cost = Cost + 133;
elseif comm == "NSN"
    Cost = Cost + 113.575;
end

%Propulsion Cost
if prop == "Nuclear Thermal"
    Cost = Cost + 3000;
elseif prop == "Chemical"
    Cost = Cost + 11.3;
elseif prop == "Solar Sail"
    Cost = Cost + 35;
elseif prop == "Plasma"
    Cost = Cost + 45;
end

%Power Source Cost
if power == "RTG Nuclear"
    Cost = Cost + 100;
elseif power == "Solar Panel/Nuclear"
    Cost = Cost + 108;
end

%Instrument Package Cost
if inst == "Minimum"
    Cost = Cost + 126.6;
elseif inst == "Mid Level"
    Cost = Cost + 178.11;
elseif inst == "High Level"
    Cost = Cost + 207.78;
end

%Kick Stage Cost
if kick == "Solid Motor"
    Cost = Cost + 13.046;
elseif kick == "Liquid"
    Cost = Cost + 38.73;
elseif kick == "Hybrid"
    Cost = Cost + 32.32;
end

