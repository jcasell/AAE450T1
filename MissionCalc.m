function [Science, Cost, Reliability, ttHP, invalid] = MissionCalc(candidateArchitecture)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: MissionCalc
%Description: Calculates results of a given candidate arcitecture mission.
%Inputs: candidateArchitecture (Design of Mission from Morph Matrix)
%Outputs: Science (Science Value), Cost (F2022 Dollars Total Mission Cost),
%Reliability (Mission Reliability), ttHP(Time to Heliopause)
%Author: Jeremy Casella
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate Instrument Package and Science
[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture);

%Calculate Total Spacecraft Mass
%Calculated using Planetary Mission SMAD table A-1
m_spacecraft = m_instr / 0.15;

%Calculate Power
%Calculated using Planetary Mission SMAD table A-2
power_spacecraft = power_instr / 0.22;

%Calculate Prop Code
[final_v, added_V] = generateC3(candidateArchitecture,m_spacecraft);

if final_v<0
    invalid =1;
else
    invalid = 0;
end

if (candidateArchitecture.Propulsion == "BHT_600") || (candidateArchitecture.Propulsion == "BHT_100")
    [m_xenon,deltaV] = modElectricProp(candidateArchitecture,m_spacecraft);
else
    deltaV = 0;
    m_xenon = 0;
end 

%Calculate Trajectory
[totalTOF,~,~] = generalTrajectory(candidateArchitecture,final_v,deltaV);
refTOF = [14.8425 4.2342 9.4374];
ttHP = totalTOF(1)+totalTOF(2);

%Calculate Telemetry Data Rate
DataRate = TelemetryFOA (candidateArchitecture,totalTOF);
refDataRate = [1.6714e22 1.2346e9 8.8774e8];

%Total Science
%Science Weights phases 1 to 3
w = [0.1 0.3 0.6];

%Bonus Science weights
w_bonus = [0.5 0.5];
Science = DataRate(1)/refDataRate(1)*sci_instr(1)^3*w(1)+DataRate(2)/refDataRate(2)*sci_instr(2)^3*w(2)+DataRate(3)/refDataRate(3)*sci_instr(3)^3*w(3);
Science = Science + DataRate(4)/refDataRate(4)*sci_instr(4)^3*w_bonus(1) + DataRate(5)/refDataRate(5)*sci_instr(5)^3*w_bonus(2);

%Total Cost
cost_vec = CostCalc(candidateArchitecture,m_spacecraft,m_xenon);
Cost = cost_vec(end);

%Return Risk
Reliability = 0;
