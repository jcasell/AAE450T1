function [m_prop,deltaV] = getDeltaV(candidateArchitecture,m_spacecraft)
% Inputs: Candidate Architecture, spacecraft mass
% Output: delta-V produced by specified electric propulsion system,
%   propellant mass required
g = 9.81;   % [m/s^2]
m_prop_frac = 0.13;     % SMAD planetary mission propulsion system mass
if candidateArchitecture.Propulsion == "BHT-600"
    % Specs for BHT-600 Hall thruster
    isp = 1500; % [s]
    m_inert = 2.8;    % [kg]
    m_inert_frac =  44 / 516;   % 44 kg tank holds 516 kg Xe (Tank: L-XTA 300 l)
    m_prop = (m_spacecraft * m_prop_frac - m_inert) / (1 + 44/516);    %  [kg]
    m_inert = m_inert + m_prop * m_inert_frac;
elseif candidateArchitecture.Propulsion == "BHT-200"
    % Specs for BHT-200 Hall thruster
    isp = 1390; % [s]
    m_inert = 1; % [kg]
    m_inert_frac =  44 / 516;
    m_prop = (m_spacecraft * m_prop_frac - m_inert) / (1 + 44/516);    %  [kg]
    m_inert = m_inert + m_prop * m_inert_frac;
elseif candidateArchitecture.Propulsion == "OMS"
    isp = 316;  % Space Shuttle OMS [s]
    lambda = 0.85; % https://link.springer.com/content/pdf/10.1007%2F978-3-642-22537-6_3.pdf
    m_prop = m_prop_frac * m_spacecraft * lambda;
    m_inert = m_prop_frac * m_spacecraft - m_prop;
else
    isp = 0;
    m_prop = 0;
    m_inert = 0;
end
% DEBUG: add more propellant mass
m_debug = 75;
m_prop = m_prop + m_debug;  % [kg]
%
deltaV = g*isp*log((m_inert + m_spacecraft + m_prop)/(m_inert + m_spacecraft)); % [m/s]
end