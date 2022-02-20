function [m_xenon,deltaV] = modElectricProp(candidateArchitecture,m_spacecraft)
%MODELECTRICPROP Output delta-V produced by specified electric propulsion system
g = 9.81;   % [m/s^2]
if candidateArchitecture.Propulsion == "BHT_600"
    % Specs for BHT-600 Hall thruster
    isp = 1500; % [s]
    m_thruster = 2.8;    % [kg]
elseif candidateArchitecture.Propulsion == "BHT_100"
    % Specs for BHT-100 Hall thruster (just to demonstrate that low thrust
    % sucks)
    isp = 1000; % [s]
    m_thruster = 1.6; % [kg]
else
    isp = 0;
    m_thruster = 0;
end
m_prop_frac = 0.13;     % SMAD planetary mission propulsion system mass
m_xenon = (m_spacecraft * m_prop_frac - m_thruster) / (1 + 44/516);    %  [kg]
m_inert = m_thruster + m_xenon * 44 / 516;  % 44 kg tank holds 516 kg Xe
deltaV = g*isp*log((m_inert + m_spacecraft + m_xenon)/(m_inert + m_spacecraft));
end