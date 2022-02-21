function [totalTOF,ENATime,LYATime,eolDist] = generalTrajectory(candidateArchitecture,v_inf,deltaV)
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
if and(candidateArchitecture.Trajectory ~= "Log Spiral",candidateArchitecture.Trajectory ~= "Solar Grav")
    [rad_list,planet1,planet2] = getCharacteristics(candidateArchitecture.Trajectory);
end

if candidateArchitecture.Trajectory == "JupSatO"
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    [stageTime,~] = detTof(a_earth,v_0,rad_list(1),fpa_arr);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = singleImpulse(planet1,v_arr,fpa_arr,32,0.7);

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(rad_list(1),v_dep,rad_list(2),fpa_dep);
    [stageTime,~] = detTof(rad_list(1),v_dep,rad_list(2),fpa_arr);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    % Add electric propulsion impulse to velocity
    v_dep = v_dep + deltaV*10^-3;
    
    %Determine Total TOF 
    [phaseTimes,ENATime,LYATime,eolDist] = coastTime(rad_list(2),v_dep,fpa_dep);
    phase1Time = phaseTimes(1); phase2Time = phaseTimes(2); phase3Time = phaseTimes(3);
    phase1Time = phase1Time + TOF;

    totalTOF = [phase1Time,phase2Time,phase3Time];
elseif candidateArchitecture.Trajectory == "MarsJupO"
    %Earth to Mars
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    [stageTime,~] = detTof(a_earth,v_0,rad_list(1),fpa_arr);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = singleImpulse(planet1,v_arr,fpa_arr,2,0.7); %2 is planetary radii for periapsis; 0.7 is delta V applied at periapsis.

    %Mars to Jupiter
    [v_arr,fpa_arr] = getFPA(rad_list(1),v_dep,rad_list(2),fpa_dep);
    [stageTime,~] = detTof(rad_list(1),v_dep,rad_list(2),fpa_arr);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    % Add electric propulsion impulse to velocity
    v_dep = v_dep + deltaV*10^-3;
    
    %Determine Total TOF 
    [phaseTimes,ENATime,LYATime,eolDist] = coastTime(rad_list(2),v_dep,fpa_dep);
    phase1Time = phaseTimes(1); phase2Time = phaseTimes(2); phase3Time = phaseTimes(3);
    phase1Time = phase1Time + TOF;

    totalTOF = [phase1Time,phase2Time,phase3Time];
elseif (candidateArchitecture.Trajectory == "JupSat") || (candidateArchitecture.Trajectory == "MarsJup")
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(a_earth,v_0,rad_list(1),0);
    TOF = detTof(a_earth,v_0,rad_list(1),fpa_arr) + TOF;
    [v_dep] = gravityAssist(planet1,v_arr,fpa_arr);

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(rad_list(1),v_dep,rad_list(2),0);
    TOF = detTof(rad_list(1),v_dep,rad_list(2),fpa_arr) + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    % Add electric propulsion impulse to velocity
    v_dep = v_dep + deltaV*10^-3;
    
    %Determine Total TOF
    [phaseTimes,ENATime,LYATime,eolDist] = coastTime(rad_list(2),v_dep,fpa_dep);
    phase1Time = phaseTimes(1); phase2Time = phaseTimes(2); phase3Time = phaseTimes(3);
    phase1Time = phase1Time + TOF;

    totalTOF = [phase1Time,phase2Time,phase3Time];
elseif (candidateArchitecture.Trajectory == "Log Spiral") || (candidateArchitecture.Trajectory == "Solar Grav")
    % Initialize Solar Sail Variables
    r0 = a_earth; rF = a_mercury; beta = 0.9;

    % Logarithmic Spiral
    [tofSpiral, vF, ~] = logarithmicSpiral(r0, rF, beta);

    % Solar Sail Radial to Sun
    v0 = vF; %Change notation; final velocity on logarithmic trajectory is initial velocity on new orbit
    [v_dep,fpa_dep,tofRadial] = radialSail(a_mercury,v0, 5.2*a_earth,beta);

    if candidateArchitecture.Trajectory == "Solar Grav"
        % Grav Assist
        [v_dep,fpa_dep] = gravityAssist("Jupiter",v_dep,fpa_dep);
    end

    % Rest of Mission
    [coastPhase,ENATime,LYATime, eolDist] = coastTime(5.2*a_earth,v_dep,fpa_dep);
    totalTOF = [tofSpiral + tofRadial + coastPhase(1), coastPhase(2), coastPhase(3) - tofSpiral - tofRadial];
end
end