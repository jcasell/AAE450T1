clc
clear
close all

candidateArchitecture.Communications = "DSN";
candidateArchitecture.Telemetry = "Ka";
candidateArchitecture.Propulsion = "BHT_600";
candidateArchitecture.Power = "RTG Nuclear";
candidateArchitecture.Instruments = "High Level";
candidateArchitecture.Trajectory = "Solar Sail";
candidateArchitecture.LaunchVehicle = "SLS";
candidateArchitecture.Kick = "Liquid";

[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture)

m_spacecraft = m_instr / 0.15

[Cost] = CostCalc(candidateArchitecture,m_spacecraft)

power_spacecraft = power_instr / 0.22

[final_v, m_pay] = generateC3( candidateArchitecture, m_instr)

totalTOF = generalTrajectory(candidateArchitecture,final_v,m_spacecraft)

DataRate = TelemetryFOA (candidateArchitecture,totalTOF)
