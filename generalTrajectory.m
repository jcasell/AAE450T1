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
a_mercury = 57909101; %radius of Mercury orbit [km]
TOF = 0;
v_earth = sqrt(2*mu_sun/a_earth); %velocity of Earth relative to Sun [km/s]
v_0 = v_inf + v_earth; %initial velocity of s/c relative to sun [km/s]

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

if (candidateArchitecture.Trajectory == "JupNepO") || (candidateArchitecture.Trajectory == "JupSatO")
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    [stageTime,finalTA] = detTof(a_earth,v_0,rad_list(1),fpa_arr);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = singleImpulse(planet1,v_arr,fpa_arr,32,0);

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
end
