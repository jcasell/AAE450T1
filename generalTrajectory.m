function [totalTOF] = generalTrajectory(candidateArchitecture,v_inf,m_spacecraft)
%% General Trajectory Function
% This function will take the mission input and apply the correct
% trajectory functions to determine the TOF of each phase
%
% Inputs: candidateArchitecture - trajectory option
%         v_inf - the escape velocity from Earth [km/s]
%
% Outputs: totalTOF - array of time of flight for each phase
%                     [phase1,phase2,phase3] [Julian Years]
%
%% Initialization
mu_sun = 132712440017.99; % grav parameter of sun [km^3/s^2]
a_earth = 149597898; %radius of Earth orbit [km]
a_mercury = 57909101; %radius of Mercury orbit [km]
TOF = 0;
v_earth = sqrt(2*mu_sun/a_earth); %velocity of Earth relative to Sun [km/s]
v_0 = v_inf + v_earth; %initial velocity of s/c relative to sun [km/s]
deltaV = 0;
%% Calculations
planet1 = "Jupiter";
if candidateArchitecture.Trajectory ~= "Solar Sail"
    rad_list = getCharacteristics(candidateArchitecture.Trajectory);
end

if (candidateArchitecture.Trajectory == "JupNep") || (candidateArchitecture.Trajectory == "JupNepO")
    planet2 = "Neptune";
elseif (candidateArchitecture.Trajectory == "JupSat") || (candidateArchitecture.Trajectory == "JupSatO")
    planet2 = "Saturn";
end

% if candidateArchitecture.Propulsion == "Electric"
%     % Determine change to TOF for all phases using X3 Hall Thruster
%     % Assumptions: impulsive maneuver, spacecraft of mass m_spacecraft can
%     % support 100 kW req. for X3 Hall Thruster
%     g_E = 9.81;         % [m/s^2]
%     isp = 2225;         % Avg. isp of X3 ion thruster
%     lambda = 0.5;       % High end estimate from Heister's Rocket Propulsion
%     m_inert = 230;      % Given mass of X3 ion thruster [kg] 
%     m_prop = lambda * m_inert / (1 - lambda);
%     MR = (m_spacecraft + m_prop + m_inert) / (m_spacecraft + m_inert);        % Rocket Equation Mass Ratio
%     dV = g_E * isp * log(MR);
%     v_0 = v_0 + dV/1000;      % Impulsive maneuver adds delta-V to Earth escape velocity
%     F = 5.4;            % Thrust [N]
%     mdot = F / g_E / isp; 
%     burnTime = m_prop/mdot/3600/24/365;  % Time to expend all propellant [yr]
% end

if (candidateArchitecture.Trajectory == "JupNepO") || (candidateArchitecture.Trajectory == "JupSatO")
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    [stageTime,finalTA] = detTof(a_earth,v_0,rad_list(1),fpa_arr);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = oberth(planet1,v_arr,fpa_arr,32,0);

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(rad_list(1),v_dep,rad_list(2),fpa_dep);
    [stageTime,~] = detTof(rad_list(1),v_dep,rad_list(2),fpa_arr);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    %Determine Total TOF 
    phaseTimes = coastTime(rad_list(2),v_dep,fpa_dep);
    phase1Time = phaseTimes(1); phase2Time = phaseTimes(2); phase3Time = phaseTimes(3);
    phase1Time = phase1Time + TOF;

    totalTOF = [phase1Time,phase2Time,phase3Time];
elseif (candidateArchitecture.Trajectory == "JupNep") || (candidateArchitecture.Trajectory == "JupSat") 
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    TOF = detTof(a_earth,v_0,rad_list(1),fpa_arr) + TOF;
    [v_dep] = gravityAssist(planet1,v_arr,fpa_arr);

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(rad_list(1),v_dep,rad_list(2),0);
    TOF = detTof(rad_list(1),v_dep,rad_list(2),fpa_arr) + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    %Determine Total TOF
    phaseTimes = coastTime(rad_list(2),v_dep,fpa_dep);
    phase1Time = phaseTimes(1); phase2Time = phaseTimes(2); phase3Time = phaseTimes(3);
    phase1Time = phase1Time + TOF;

    totalTOF = [phase1Time,phase2Time,phase3Time];
elseif candidateArchitecture.Trajectory == "Solar Sail"
    r0 = a_earth; rF = a_mercury; beta = 0.2;
    [tofSpiral, vF, reqFpa] = logarithmicSpiral(r0, rF, beta);
    v0 = vF; %Change notation; final velocity on logarithmic trajectory is initial velocity on new orbit
    coast = radialSail(a_mercury,v0, 110*a_earth,beta);
    coastPhase = coastTimeMod(rF, vF,beta, reqFpa);
    totalTOF = [tofSpiral + coastPhase(1), coastPhase(2), coastPhase(3)];
end
if (candidateArchitecture.Propulsion == "BHT_100") || (candidateArchitecture.Propulsion == "BHT_600")
    % Recalculate TOF with added electric propulsion delta-V
    deltaV = ElectricPropulsion(candidateArchitecture, m_spacecraft);
    % Use this delta-V for unique trajectory calc
end
end