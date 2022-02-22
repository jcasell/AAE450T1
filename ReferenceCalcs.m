clc
clear
close all

candidateArchitecture.Communications = "DSN";
candidateArchitecture.Telemetry = "Ka";
candidateArchitecture.Propulsion = "Chemical";
candidateArchitecture.Power = "RTG Nuclear";
candidateArchitecture.Instruments = "Mid Level";
candidateArchitecture.Trajectory = "JupSatO";
candidateArchitecture.LaunchVehicle = "SLS Block 2";
candidateArchitecture.Kick = "Centaur V & Star 48BV";
candidateArchitecture.num_Kick = 2;

[science, cost, reliability, ttHP, invalid] = MissionCalc(candidateArchitecture)
cost = cost*1.3
