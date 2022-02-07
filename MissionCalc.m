function [Science, Cost, Reliability, ttHP] = MissionCalc(candidateArchitecture)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: MissionCalc
%Description: Calculaes results of a given candidate arcitecture mission.
%Inputs: candidateArchitecture (Design of Mission from Morph Matrix)
%Outputs: Science (Science Value), Cost (F2022 Dollars Total Mission Cost),
%Reliability (Mission Reliability), ttHP(Time to Heliopause)
%Author: Jeremy Casella
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate Instrument Package and Science
[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture)

%Calculate Telemetry Data Rate
DataRate = TelemetryFOA (candidateArchitecture)
refDataRate = [14.6331 9.6722 6.5036]
%Calculate Total Spacecraft Mass
%Calculated using Planetary Mission SMAD table A-1
m_spacecraft = m_instr / 0.15;

%Calculate Power
%Calculated using Planetary Mission SMAD table A-2
power_spacecraft = power_instr / 0.22;

%Calculate Prop Code
[final_v, m_pay] = generateC3( candidateArchitecture, m_spacecraft);

%Calculate Trajectory
[totalTOF] = generalTrajectory(candidateArchitecture,final_v)
refTOF = [1 1 1];
ttHP = totalTOF(3)

%Total Science
%Science Weights phases 1 to 3
w = [1 2 10];

Science = DataRate(1)/refDataRate(1)*sci_instr(1)*totalTOF(1)/refTOF(1)*w(1)+DataRate(2)/refDataRate(2)*sci_instr(2)*totalTOF(2)/refTOF(2)*w(2)+DataRate(3)/refDataRate(3)*sci_instr(3)*totalTOF(3)/refTOF(3)*w(3);

%Total Cost
Cost = CostCalc(candidateArchitecture);

%Return Risk
Reliability = 0;
