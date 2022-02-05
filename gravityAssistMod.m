function [v_eq,alpha,delta,v_dep,pass_dist] = gravityAssistMod(candidateArchitecture)
%% Gravity Assist Calculation Function
% This function will determine the changed trajectory of the spacecraft
% after a gravity assist. Assumes that departure FPA is 0 and determines
% pass distance based on that constraint.
%
% Inputs: candidateArchitecture - array of designs
%         v_arr - arrival velocity of s/c [km/s]
%         fpa_arr - arrival flight path angle [deg]
%
% Outputs: v_eq - equivalent delta v from pass [km/s]
%          alpha - angle of velocity change [deg]
%          delta - turn angle of pass [deg]
%          v_dep - departure velocity of s/c [km/s]
%          pass_dist - pass distance to planet [km]
%
%% Initialization
mu_sun = 132712440017.99; % grav parameter of sun [km^3/s^2] 
a_Earth = 149597898; %Semimajor axis of Earth orbit [km]
v_Earth = sqrt(2*mu_sun/a_Earth);

% Switch statement to determine SMA of planet orbit [km], Grav parameter
% [km^3/s^2] and radius of planet [km]
char_energy = candidateArchitecture.CharacteristicEnergy; %Not sure if this is how MATLAB OOP works

v_inf = sqrt(char_energy); v_dep = v_Earth + v_inf; %Assumes perfectly tangential Earth departure

switch candidateArchitecture.GravityAssist
    case "Venus"
        a_planet = 108207284;
        mu_planet = 324858.5988;
        r_planet = 6051.9;
    case "Mars"
        a_planet = 227944135;
        mu_planet = 42828.3142;
        r_planet = 3397;
    case "Jupiter"
        a_planet = 778279959;
        mu_planet = 126712767.8578;
        r_planet = 71492;
    case "Saturn"
        a_planet = 1427387908;
        mu_planet = 37940626.0611;
        r_planet = 60268;
    case "Uranus"
        a_planet = 2870480873;
        mu_planet = 5794549.0070;
        r_planet = 25559;
    case "Neptune"
        a_planet = 4498337290;
        mu_planet = 6836534.0638;
        r_planet = 25269;
    case "None"
        a_planet = 0; %or just skips function?
        mu_planet = 0; %or do this outside of function and use each case as input
        r_planet = 0;
end

[v_arr, fpa_arr] = getFPA(a_Earth,v_dep,a_planet); %Gets arrival velocity and flight path angle at second planet

%% Calculations
v_planet = sqrt(mu_sun / a_planet); %heliocentric velocity of planet used for pass [km/s]
v_inf = sqrt(v_planet^2 + v_arr^2 - (2*v_planet*v_arr*cosd(fpa_arr))); %hyperbolic velocity around planet [km/s]

% Departure
v_dep = v_planet + v_inf; %departure velocity [km/s]
fpa_dep = 0; %departure flight path angle [deg]

% Equivalent deltaV
delta_fpa = abs(fpa_arr - fpa_dep);
v_eq = sqrt(v_dep^2 + v_arr^2 - (2*v_dep*v_arr*cosd(delta_fpa))); %equivalent deltaV from pass
beta1 = asind(v_dep*sind(delta_fpa)/v_eq);
beta2 = 180 - beta1;

% Quadrant Check
check1 = sqrt(v_eq^2 + v_arr^2 - (2*v_eq*v_arr*cosd(beta1)));
check2 = sqrt(v_eq^2 + v_arr^2 - (2*v_eq*v_arr*cosd(beta2)));

if floor(check1) == floor(v_dep)
    beta = beta1;
elseif floor(check2) == floor(v_dep)
    beta = beta2;
else
    fprintf('You fucked up')
end

alpha = 180 - beta;

% Hyperbolic Pass
eta = 180 - beta - fpa_arr; %arbitrary angle in velocity triangle
delta1 = asind(v_eq / v_inf * sind(eta)); %turn angle
delta2 = 180 - delta1;

% Quadrant Check
check1 = sqrt(v_inf^2 + v_inf^2 - (2*v_inf*v_inf*cosd(delta1)));
check2 = sqrt(v_inf^2 + v_inf^2 - (2*v_inf*v_inf*cosd(delta2)));
if floor(check1) == floor(v_eq)
    delta = delta1;
elseif floor(check2) == floor(v_eq)
    delta = delta2;
else
    fprintf('You fucked up')
end

a_hyp = -mu_planet / (v_inf^2); %semimajor axis of hyperbola
e_hyp = 1 / sind(delta/2); %eccentricity of hyperbola
rp = (e_hyp - 1)*abs(a_hyp); %radius of periapsis
pass_dist = rp - r_planet; %pass distance to planet [km]
if pass_dist < 0
    fprintf('Collision with Planet')
end
b_hyp = abs(a_hyp)*sqrt(e_hyp^2 - 1); %semiminor axis of hyperbola

end
