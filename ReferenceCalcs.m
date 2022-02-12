clc
clear
close all

candidateArchitecture.Communications = "DSN";
candidateArchitecture.Telemetry = "Ka";
candidateArchitecture.Propulsion = "Solar Sail";
candidateArchitecture.Power = "RTG Nuclear";
candidateArchitecture.Instruments = "High Level";
candidateArchitecture.Trajectory = "JupNep";
candidateArchitecture.LaunchVehicle = "SLS";
candidateArchitecture.Kick = "Liquid";

[Cost] = CostCalc(candidateArchitecture)

[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture)

m_spacecraft = m_instr / 0.15

power_spacecraft = power_instr / 0.22

[final_v, m_pay] = generateC3( candidateArchitecture, m_instr)

totalTOF = generalTrajectory(candidateArchitecture,final_v)

DataRate = TelemetryFOA (candidateArchitecture,totalTOF)
