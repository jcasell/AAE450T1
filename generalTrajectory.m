function [totalTOF,ENATime,LYATime,eolDist,parameterList] = generalTrajectory(candidateArchitecture,v_inf,m_spacecraft, addedVelocity)
%% General Trajectory Function
% This function will take the mission input and apply the correct
% trajectory functions to determine the TOF of each phase
%
% Inputs: candidateArchitecture - trajectory option
%         v_inf - the escape velocity from Earth [km/s]
%         deltaV - delta V from onboard propulsion system
% Outputs: totalTOF - array of time of flight for each phase
%                     [phase1,phase2,phase3] [Julian Years]
%           ENATime - time from 250 AU - EOL [Julian Years]
%           LYATime - time from 300 AU - EOL [Julian Years]
%           eolDist - distance at 35 years [km]
%           parameterList - 
%
%% Initialization
mu_sun = 132712440017.99; % grav parameter of sun [km^3/s^2]
mu_earth = 398600.4415; % grav parameter of Earth [km^3/s^2]
a_earth = 149597898; %radius of Earth orbit [km]
a_mercury = 57909101; %radius of Mercury orbit [km]
TOF = 0;

%Determine velocity at periapsis of GEOCENTRIC FRAME
specEn = 0.5*v_inf^2;

sma = -mu_earth / (2*specEn);
rPeri = 6378.1363 + 400; %Assume initial parking orbit of 400km altitude
v_circ = sqrt(mu_earth / rPeri);

vPeri = sqrt(2*mu_earth * (1/rPeri - 1/(2*sma))) + (addedVelocity/1000); %Calculate velocity at periapsis with kick stage delta V
sma = 0.5 * (mu_earth / ((mu_earth / rPeri) - (vPeri^2 / 2))); %Calculate semimajor axis of geocentric escape orbit after kick stages
specEn = -mu_earth / (2*sma);
v_inf = sqrt(2*specEn);

v_earth = sqrt(2*mu_sun/a_earth); %velocity of Earth relative to Sun [km/s]
v_0 = v_inf + v_earth; %initial velocity of s/c relative to sun [km/s]
deltaV = 0.7;   % Desired chemical dV for Oberth burn [km/s]
m_pay_elec = m_spacecraft;
parameterList = zeros(5,5);

%% Calculations
if and(candidateArchitecture.Trajectory ~= "Log Spiral",candidateArchitecture.Trajectory ~= "Solar Grav")
    [rad_list,planet1,planet2] = getCharacteristics(candidateArchitecture.Trajectory);
end

% Burns electric engine from Earth - 0.2 AU from First Planet
if candidateArchitecture.Propulsion == "BHT-200"
    au2km = 149597870.691;
    buffer = .2*au2km; %km (buffer to start and stop eprop)
    [v_0,currentR,fpa_e,stageTime,mp_res] = Burn_eProp(m_pay_elec,v_0,a_earth,0,rad_list(1)-buffer);
    TOF = stageTime + TOF;
else
    currentR = a_earth;
    fpa_e = 0;
end

if (candidateArchitecture.Trajectory == "JupSatO") || (candidateArchitecture.Trajectory == "MarsJupO")
    % Chemical propulsion system for powered gravity assist (Oberth)
    isp = 300;  % Draco specific impulse [s]
    lambda = 0.90;  % Propellant mass fraction for SpaceX Draco thruster
    m_prop_chem = m_pay_elec * (exp(deltaV*1000/isp/9.81) - 1) / (1 + (1-lambda)/lambda*(1 - exp(deltaV*1000/isp/9.81)));
    % Chemical propulsion system is payload for electric propulsion system
    m_pay_elec = m_pay_elec + m_prop_chem;
    
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(currentR,v_0,rad_list(1),fpa_e);
    [stageTime,initialTA,finalTA, sma, ecc] = detTof(currentR,v_0,rad_list(1),fpa_e);
    currentR = rad_list(1);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = singleImpulse(planet1,v_arr,fpa_arr,deltaV);

    if candidateArchitecture.Propulsion == "BHT-200" && mp_res > 0
        [v_dep,currentR,fpa_dep,stageTime,mp_res] = Burn_eProp(m_pay_elec,v_dep,currentR+buffer,fpa_dep,rad_list(2)-buffer,mp_res);
        TOF = stageTime + TOF;
    end
    parameterList(1,:) = [currentR,sma,ecc,initialTA,finalTA];

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(currentR,v_dep,rad_list(2),fpa_dep);
    [stageTime,initialTA,finalTA, sma, ecc] = detTof(currentR,v_dep,rad_list(2),fpa_dep);
    currentR = rad_list(2);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);

    if candidateArchitecture.Propulsion == "BHT-200" && mp_res > 0
        [v_dep,currentR,fpa_dep,stageTime] = Burn_eProp(m_pay_elec,v_dep,rad_list(2)+buffer,fpa_dep,0,mp_res);
        TOF = stageTime + TOF;
    end
    parameterList(2,:) = [currentR,sma,ecc,initialTA,finalTA];

    %Determine Total TOF
    [phaseTimes,ENATime,LYATime,eolDist] = coastTime(currentR,v_dep,fpa_dep);
    phase1Time = phaseTimes(1); phase2Time = phaseTimes(2); phase3Time = phaseTimes(3);
    phase1Time = phase1Time + TOF;
    totalTOF = [phase1Time,phase2Time,phase3Time];

elseif (candidateArchitecture.Trajectory == "JupSat") || (candidateArchitecture.Trajectory == "MarsJup")
    %Earth to First Planet
    [v_arr,fpa_arr] = getFPA(currentR,v_0,rad_list(1),fpa_e);
    [stageTime,initialTA,finalTA, sma, ecc] = detTof(currentR,v_0,rad_list(1),fpa_e);
    
    parameterList(1,:) = [currentR,sma,ecc,initialTA,finalTA];
    
    currentR = rad_list(1);
    TOF = stageTime + TOF;
    [v_dep,fpa_dep] = gravityAssist(planet1,v_arr,fpa_arr); 

    if candidateArchitecture.Propulsion == "BHT-200" && mp_res > 0
        [v_dep,currentR,fpa_dep,stageTime,mp_res] = Burn_eProp(m_pay_elec,v_dep,currentR+buffer,fpa_dep,rad_list(2)-buffer,mp_res);
        TOF = stageTime + TOF;
    end

    %First Planet to Second Planet
    [v_arr,fpa_arr] = getFPA(currentR,v_dep,rad_list(2),fpa_dep);
    [stageTime,initialTA,finalTA, sma, ecc] = detTof(currentR,v_dep,rad_list(2),fpa_dep);
    TOF = stageTime + TOF;
    currentR = rad_list(2);
    [v_dep,fpa_dep] = gravityAssist(planet2,v_arr,fpa_arr);
    parameterList(1,:) = [currentR,sma,ecc,initialTA,finalTA];

    if candidateArchitecture.Propulsion == "BHT-200" && mp_res > 0
        [v_dep,currentR,fpa_dep,stageTime] = Burn_eProp(m_pay_elec,v_dep,rad_list(2)+buffer,fpa_dep,0,mp_res);
        TOF = stageTime + TOF;
    end
    parameterList(2,:) = [currentR,sma,ecc,initialTA,finalTA];

    %Determine Total TOF
    [phaseTimes,ENATime,LYATime,eolDist] = coastTime(currentR,v_dep,fpa_dep);
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
