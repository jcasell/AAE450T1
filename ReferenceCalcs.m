clc
clear
close all

candidateArchitecture.Communications = "DSN";
candidateArchitecture.Telemetry = "Ka";
candidateArchitecture.Propulsion = "Chemical";
candidateArchitecture.Power = "RTG Nuclear";
candidateArchitecture.Instruments = "Mid Level";
%candidateArchitecture.Trajectory = "Solar Sail";
candidateArchitecture.Trajectory = "JupSatO";
candidateArchitecture.LaunchVehicle = "SLS Block 2";
candidateArchitecture.Kick = "Star48BV";
candidateArchitecture.num_Kick = 1;

[science, cost, reliability, ttHP, invalid] = MissionCalc(candidateArchitecture)


[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture)

m_spacecraft = m_instr / 0.15

cost_vec = CostCalc(candidateArchitecture,m_spacecraft)
total_cost = cost_vec(end)

power_spacecraft = power_instr / 0.22

[final_v, invalid, added_V] = generateC3(candidateArchitecture,m_spacecraft);

[totalTOF,~,~,endOfLifeDist] = generalTrajectory(candidateArchitecture,final_v,m_spacecraft)

DataRate = TelemetryFOA (candidateArchitecture,totalTOF,endOfLifeDist)
