function [totalTOF] = generalTrajectory(candidateArchitecture,v_inf)
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
TOF = 0;
v_earth = sqrt(2*mu_sun/a_earth); %velocity of Earth relative to Sun [km/s]
v_0 = v_inf + v_earth; %initial velocity of s/c relative to sun [km/s]

%% Calculations
rad_list = getCharacteristics(candidateArchitecture.Trajectory);
planet1 = "Jupiter";
if (candidateArchitecture.Trajectory == "JupNep") || (candidateArchitecture.Trajectory == "JupNep_O")
    planet2 = "Neptune";
elseif (candidateArchitecture.Trajectory == "JupSat") || (candidateArchitecture.Trajectory == "JupSat_O")
    planet2 = "Saturn";
end

if (candidateArchitecture.Trajectory == "JupNep_O") || (candidateArchitecture.Trajectory == "JupSat_O")
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    TOF = detTof(a_earth,v_0,rad_list(1)) + TOF;
    [v_dep,fpa_dep] = oberth(planet1,v_arr,fpa_arr,32,0);

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(rad_list(1),v_dep,rad_list(2),fpa_dep);
    TOF = detTof(rad_list(1),v_dep,rad_list(2)) + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    %Determine Total TOF 
    [phase1Time,phase2Time,phase3Time] = coastTime(rad_list(2),v_dep,fpa_dep);
    phase1Time = phase1Time + TOF;

    totalTOF = [phase1Time,phase2Time,phase3Time];
elseif (candidateArchitecture.Trajectory == "JupNep") || (candidateArchitecture.Trajectory == "JupSat") 
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    TOF = detTof(a_earth,v_0,rad_list(1)) + TOF;
    [v_dep] = gravityAssist(planet1,v_arr,fpa_arr);

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(rad_list(1),v_dep,rad_list(2),0);
    TOF = detTof(rad_list(1),v_dep,rad_list(2)) + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    %Determine Total TOF
    [phase1Time,phase2Time,phase3Time] = coastTime(rad_list(2),v_dep,fpa_dep);
    phase1Time = phase1Time + TOF;

    totalTOF = [phase1Time,phase2Time,phase3Time];
end
end
