function [m_prop,deltaV] = modElectricProp(candidateArchitecture,m_spacecraft)
%MODELECTRICPROP Output delta-V produced by specified electric propulsion system
g = 9.81;   % [m/s^2]
if candidateArchitecture.Propulsion == "BHT_600"
    % Specs for BHT-600 Hall thruster
    isp = 1500; % [s]
    m_inert = 2.8;    % [kg]
elseif candidateArchitecture.Propulsion == "BHT_100"
    % Specs for BHT-100 Hall thruster (just to demonstrate that low thrust
    % sucks)
    isp = 1000; % [s]
    m_inert = 1.6; % [kg]
else
    isp = 0;
    m_inert = 0;
end
% START DEBUG
debug_mass = 200;   % Manually add more propellant [kg]
% END DEBUG
m_prop = m_spacecraft * 0.13 + debug_mass; % [kg]
% Add estimate Xenon tank mass (extrapolated from X-LTA 300 l tank)
m_tank_frac = 44 / 516;     % 44 kg tank holds 516 kg Xe
m_inert = m_inert + m_prop * m_tank_frac;
deltaV = g*isp*log((m_inert + m_spacecraft + m_prop)/(m_inert + m_spacecraft));
end