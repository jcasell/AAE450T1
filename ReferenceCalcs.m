clc
clear
close all

candidateArchitecture.Communications = "DSN";
candidateArchitecture.Telemetry = "Ka";
candidateArchitecture.Propulsion = "BHT-200";
candidateArchitecture.Power = "RTG Nuclear";
candidateArchitecture.Instruments = "Mid Level";
candidateArchitecture.Trajectory = "MarsJup";
candidateArchitecture.LaunchVehicle = "SLS Block 2";
candidateArchitecture.Kick = "Centaur V & Star 48BV";
candidateArchitecture.num_Kick = 2;

[science, cost, reliability, ttHP, invalid] = MissionCalc(candidateArchitecture)

[final_v, invalid, added_V] = generateC3( candidateArchitecture, 800 )



%Calculate Instrument Package and Science
[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture);

%Calculate Total Spacecraft Mass
%Calculated using Planetary Mission SMAD table A-1
m_spacecraft = m_instr / 0.15

%Calculate Power
%Calculated using Planetary Mission SMAD table A-2
power_spacecraft = power_instr / 0.22

% %Calculate Prop Code
% [final_v, invalid, added_V] = generateC3(candidateArchitecture,m_spacecraft)
% 
% if invalid == true
%     Science = 0;
%     Cost = 0;
%     Reliability = 0;
%     ttHP = 0;
%     return
% end
% 
% if (candidateArchitecture.Propulsion == "BHT_600") || (candidateArchitecture.Propulsion == "BHT_100")
%     [m_xenon,deltaV] = modElectricProp(candidateArchitecture,m_spacecraft);
% else
%     deltaV = 0;
%     m_xenon = 0;
% end 
% 
% %Calculate Trajectory
% [totalTOF,ENATime,LYATime,EndOfLifeS] = generalTrajectory(candidateArchitecture,final_v,deltaV)
% 
% 
% %Calculate Telemetry Data Rate
% DataRate = TelemetryFOA (candidateArchitecture,totalTOF,ENATime,LYATime,EndOfLifeS);