function [v_dep,fpa_dep] = oberth(planet_name,v_arr,fpa_arr,pass_dist,deltaV)
%% Gravity Assist Calculation Function
% This function will determine the changed trajectory of the spacecraft
% after a gravity assist
%
% Inputs: planet_name - planet being used for maneuver
%         v_arr - arrival velocity of s/c [km/s]
%         fpa_arr - arrival flight path angle [deg]
%         pass_dist - constant to be applied to pass distance to planet 
%         deltaV - deltaV during the oberth [km/s]
%
% Outputs: v_dep - departure velocity of s/c [km/s]
%          fpa_dep - departure flight path angle [deg]
%
%% Initialization
mu_sun = 132712440017.99; % grav parameter of sun [km^3/s^2]

% Switch statement to determine SMA of planet orbit [km], Grav parameter
% [km^3/s^2] and radius of planet [km]
switch planet_name
    case "Jupiter"
        a_planet = 778279959;
        mu_planet = 126712767.8578;
        r_planet = 71492;
    case "Saturn"
        a_planet = 1427387908;
        mu_planet = 37940626.0611;
        r_planet = 60268;
    case "Neptune"
        a_planet = 4498337290;
        mu_planet = 6836534.0638;
        r_planet = 25269;
end

r_p = pass_dist*r_planet + r_planet; %periapsis of orbit [km]

%% Calculations
v_planet = sqrt(mu_sun / a_planet); %heliocentric velocity of planet used for pass [km/s]
v_inf = sqrt(v_planet^2 + v_arr^2 - (2*v_planet*v_arr*cosd(fpa_arr))); %hyperbolic velocity around planet [km/s]

% Hyperbolic Pass
a_hyp = -mu_planet / (v_inf^2); %semimajor axis of hyperbola
e_hyp = (r_p / abs(a_hyp)) + 1; %eccentricity of hyperbola
delta = 2 * asind(1 / e_hyp); %turn angle
b_hyp = abs(a_hyp)*sqrt(e_hyp^2 - 1); %semiminor axis of hyperbola
v_p = sqrt((2*mu_planet)*((1/b_hyp)+(1/abs(a_hyp))));   %velocity of periapsis 
v_p_impulse = v_p + deltaV; %velocity at periapsis after impulse
a_new_hyp = (-.5)*((mu_planet)/(((v_p_impulse^2)/2) - (mu_planet/b_hyp)));  %semimajor axis of hyperbola after manuever
e_new_hyp = (b_hyp / abs(a_new_hyp)) + 1;      %eccentricity of hyperbola after manuever
delta_new = 2 * asind(1 / e_new_hyp);           %turn angle after manuever

% Cosine Law and Angles
eta = asind(v_arr*sind(fpa_arr)/v_inf); %arbitrary angle in velocity triangle [deg]

% Departure
v_dep = sqrt(v_planet^2 + v_inf^2 - (2*v_planet*v_inf*cosd(eta+delta_new))); %departure velocity after manuever [km/s]
fpa_dep = asind(v_inf*sind(eta+delta_new)/v_dep); %departure flight path angle after manuever [deg]

% Equivalent deltaV
delta_fpa = abs(fpa_arr - fpa_dep);
v_eq = sqrt(v_dep^2 + v_arr^2 - (2*v_dep*v_arr*cosd(delta_fpa))); %equivalent deltaV from pass
beta1 = asind(v_dep*sind(delta_fpa)/v_eq);
beta2 = 180 - beta1;

% Quadrant Check
check1 = sqrt(v_eq^2 + v_arr^2 - (2*v_eq*v_arr*cosd(beta1)));
check2 = sqrt(v_eq^2 + v_arr^2 - (2*v_eq*v_arr*cosd(beta2)));

if abs(check1 - v_dep) < 0.5
    beta = beta1;
elseif abs(check2 - v_dep) < 0.5
    beta = beta2;
else
    fprintf('You fucked up\n')
end
alpha = 180 - beta; %angle of change in heliocentric velocity [deg]

end
