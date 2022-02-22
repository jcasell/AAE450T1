clc
clear
close all

candidateArchitecture.Communications = "DSN";
candidateArchitecture.Telemetry = "Ka";
candidateArchitecture.Propulsion = "BHT-200";
candidateArchitecture.Power = "RTG Nuclear";
candidateArchitecture.Instruments = "Mid Level";
candidateArchitecture.Trajectory = "JupSat";
candidateArchitecture.LaunchVehicle = "SLS Block 2";
candidateArchitecture.Kick = "Centaur V & Star 48BV";
candidateArchitecture.num_Kick = 2;

[science, cost, reliability, ttHP, invalid] = MissionCalc(candidateArchitecture)
cost = cost*1.3
