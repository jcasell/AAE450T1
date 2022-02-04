function [Science, Cost, Mass] = MissionCalc(mission)
ComNet = mission(1); %Communication Network Choice
Prop = mission(2);   %Propulsion Choice
Power = mission(3);  %Power Source Choice
Instr = mission(4);    %Instrumentation Choice
Traj = mission(6); %Orbital Maneuver Choice
Craft = mission(6);    %Number of Spacecraft Choice
LaunchV = mission(7);    %Launch Vehicle Choice
Kick = mission(8);   %Kick Stages Choice

%Calculate Instrument Package and Science
[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(Instr)

%Calculate Telemetry Data Rate

%Calculate Total Spacecraft Mass
%Calculated using Planetary Mission SMAD table A-1
m_spacecraft = m_instr / 0.15;

%Calculate Power
%Calculated using Planetary Mission SMAD table A-2
power_spacecraft = power_instr / 0.22;

%Calculate Prop Code

%Calculate Trajectory



%Total Science

%Total Cost

%Return Risk
