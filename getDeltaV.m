function [burnTime,m_prop,deltaV] = getDeltaV(candidateArchitecture,m_spacecraft)
% Inputs: Candidate Architecture, spacecraft mass
% Output: deltaV - delta-V delivered by onboard propulsion system [m/s]
g = 9.81;   % [m/s^2]
F = 0;
isp = 0;
m_prop = 0;
m_inert = 0;
% DEBUG: increase fraction of spacecraft mass that is propulsion system
m_debug = 0.00;
%
m_prop_frac = 0.13 + m_debug;    % SMAD planetary mission propulsion system mass
if candidateArchitecture.Propulsion == "BHT-600"
    % Specs for BHT-600 Hall thruster
    F = 39 / 1000;  % [N]
    isp = 1500; % [s]
    m_inert = 2.8;    % [kg]
    m_inert_frac =  44 / 516;   % 44 kg tank holds 516 kg Xe (Tank: L-XTA 300 l)
    m_prop = (m_spacecraft * m_prop_frac - m_inert) / (1 + 44/516);    %  [kg]
    m_inert = m_inert + m_prop * m_inert_frac;
elseif candidateArchitecture.Propulsion == "BHT-200"
    % Specs for BHT-200 Hall thruster
    F = 13 / 1000;  % [N]
    isp = 1390; % [s]
    m_inert = 1; % [kg]
    m_inert_frac =  44 / 516;
    m_prop = (m_spacecraft * m_prop_frac - m_inert) / (1 + 44/516);    %  [kg]
    m_inert = m_inert + m_prop * m_inert_frac;
elseif candidateArchitecture.Propulsion == "Chemical"
    isp = 300;  % SpaceX Dragon Draco [s]
    F = 400;    % [N]
    lambda = 0.85; % (complete guess)
    m_prop = m_prop_frac * m_spacecraft * lambda;
    m_inert = m_prop_frac * m_spacecraft - m_prop;
else
    isp = 0;
    m_prop = 0;
    m_inert = 0;
    F = 0;
end
m_dot = F / isp / g;    % [kg/s]
burnTime = m_prop / m_dot;  % Used for prop cost calc [s]
deltaV = g*isp*log((m_inert + m_spacecraft + m_prop)/(m_inert + m_spacecraft)); % [m/s]
end