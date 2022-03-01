function [Science, Cost, Reliability, ttHP, invalid,orbitalParams] = MissionCalc(candidateArchitecture)
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
[final_v, invalid, added_V] = generateC3(candidateArchitecture,m_spacecraft);

if invalid == true
    Science = 0;
    Cost = 0;
    Reliability = 0;
    ttHP = 0;
    return
end

[burnTime,m_prop,deltaV] = getDeltaV(candidateArchitecture,m_spacecraft);

%Calculate Trajectory
[totalTOF,ENATime,LYATime,EndOfLifeS,orbitalParams] = generalTrajectory(candidateArchitecture,final_v,m_spacecraft);
ttHP = totalTOF(1)+totalTOF(2);

%Calculate Telemetry Data Rate
DataRate = TelemetryFOA (candidateArchitecture,totalTOF,ENATime,LYATime,EndOfLifeS);
refDataRate = [1.3923e19 3.0394e6 3.1723e6 1.1091e6 1.3236e5];

%Total Science
%Science Weights phases 1 to 3
w = [0.1 0.3 0.6];

%Bonus Science weights
w_bonus = [0.1 0.1];
Science = DataRate(1)/refDataRate(1)*sci_instr(1)^3*w(1)+DataRate(2)/refDataRate(2)*sci_instr(2)^3*w(2)+DataRate(3)/refDataRate(3)*sci_instr(3)^3*w(3);
Science = Science + DataRate(4)/refDataRate(4)*sci_instr(4)^3*w_bonus(1) + DataRate(5)/refDataRate(5)*sci_instr(5)^3*w_bonus(2);

%Total Cost
cost_vec = CostCalc(candidateArchitecture,m_spacecraft,m_prop,burnTime);
Cost = cost_vec(end);

%Return Risk
Reliability = 0;
