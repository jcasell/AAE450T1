function [Science, Cost, Mass] = MissionCalc(mission)
ComNet = mission(1); %Communication Network Choice
Prop = mission(2);   %Propulsion Choice
Power = mission(3);  %Power Source Choice
Instr = mission(4);    %Instrumentation Choice
Traj = mission(6); %Orbital Maneuver Choice
Craft = mission(6);    %Number of Spacecraft Choice
LaunchV = mission(7);    %Launch Vehicle Choice
Kick = mission(8);   %Kick Stages Choice

