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

[science, cost, reliability, ttHP, invalid,orbitalParams] = MissionCalc(candidateArchitecture)
[Science_instrument, Cost_instrument, Mass_instrument, Power_instrument] = Instrumentation(candidateArchitecture)
m_spacecraft = Mass_instrument / 0.15;
[burnTime,m_prop,deltaV] = getDeltaV(candidateArchitecture,m_spacecraft);
cost_vec = CostCalc(candidateArchitecture,m_spacecraft,m_prop,burnTime);

cost = cost*1.3
