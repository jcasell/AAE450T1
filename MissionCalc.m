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

%Calculate Total Spacecraft Mass
%Calculated using Planetary Mission SMAD table A-1
m_spacecraft = m_instr / 0.15;

%Calculate Power
%Calculated using Planetary Mission SMAD table A-2
power_spacecraft = power_instr / 0.22;

%Calculate Prop Code
[final_v, m_pay] = generateC3(candidateArchitecture, m_instr);


%Calculate Trajectory

tthp = 0;

%Total Science
%Science Weights phases 1 to 3
w = [1 2 10];

Science = DataRate(1)*sci_instr(1)*tof(1)*w(1)+DataRate(2)*sci_instr(2)*tof(2)*w(2)+DataRate(3)*sci_instr(3)*tof(3)*w(3)

%Total Cost
Cost = 0;

%Return Risk
Risk = 0;
