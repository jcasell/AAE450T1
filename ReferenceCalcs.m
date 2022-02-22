clc
clear
close all

candidateArchitecture.Communications = "DSN";
candidateArchitecture.Telemetry = "Ka";
candidateArchitecture.Propulsion = "Chemical";
candidateArchitecture.Power = "RTG Nuclear";
candidateArchitecture.Instruments = "High Level";
candidateArchitecture.Trajectory = "JupSatO";
candidateArchitecture.LaunchVehicle = "Starship";
candidateArchitecture.Kick = "Centaur V & Nuclear";
candidateArchitecture.num_Kick = 2;

[science, cost, reliability, ttHP, invalid] = MissionCalc(candidateArchitecture)
cost = cost*1.3
