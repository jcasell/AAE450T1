function [Science, Cost, Mass, ttHP] = MissionCalc(candidateArchitecture)

%Calculate Instrument Package and Science
[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture)

%Calculate Telemetry Data Rate


%Calculate Total Spacecraft Mass
%Calculated using Planetary Mission SMAD table A-1
m_spacecraft = m_instr / 0.15;

%Calculate Power
%Calculated using Planetary Mission SMAD table A-2
power_spacecraft = power_instr / 0.22;

%Calculate Prop Code

%Calculate Trajectory

tthp = 0;

%Total Science
Science = 0;

%Total Cost
Cost = 0;

%Return Risk
Risk = 0;
