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
candidateArchitecture.LaunchVehicle = "SLS";
candidateArchitecture.Kick = "Liquid";

[sci_instr, cost_instr, m_instr, power_instr] = Instrumentation(candidateArchitecture)

m_spacecraft = m_instr / 0.15

power_spacecraft = power_instr / 0.22

[final_v, m_pay] = generateC3( candidateArchitecture, m_instr)

if (candidateArchitecture.Propulsion == "BHT_600") || (candidateArchitecture.Propulsion == "BHT_100")
    [m_xenon,deltaV] = modElectricProp(candidateArchitecture,m_spacecraft);
else
    deltaV = 0;
    m_xenon = 0;
end 

totalTOF = generalTrajectory(candidateArchitecture,final_v,m_spacecraft)

DataRate = TelemetryFOA (candidateArchitecture,totalTOF)

cost_vec = CostCalc(candidateArchitecture,m_spacecraft)
Cost = cost_vec(end)