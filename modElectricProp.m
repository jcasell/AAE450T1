function [deltaV] = modElectricProp(candidateArchitecture,m_spacecraft)
%MODELECTRICPROP Output delta-V produced by specified electric propulsion system
%   Detailed explanation goes here
g = 9.81;
isp = 1500;
m_prop = m_spacecraft * 0.13; % [kg]
% DEBUG
m_prop = m_prop + 200;
%
m_inert = 3;    % [kg]
deltaV = g*isp*log((m_inert + m_spacecraft + m_prop)/(m_inert + m_spacecraft));
end