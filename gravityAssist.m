function [v_dep,fpa_dep] = gravityAssist(planet_name,v_arr,fpa_arr)
%% Gravity Assist Calculation Function
% This function will determine the changed trajectory of the spacecraft
% after a gravity assist. Assumes that departure FPA is 0 and determines
% pass distance based on that constraint.
%
% Inputs: planet_name - planet for gravity assist
%         v_arr - arrival velocity of s/c [km/s]
%         fpa_arr - arrival flight path angle [deg]
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
        pass_scalar = 16;
    case "Saturn"
        a_planet = 1427387908;
        mu_planet = 37940626.0611;
        r_planet = 60268;
        pass_scalar = 10;
    case "Neptune"
        a_planet = 4498337290;
        mu_planet = 6836534.0638;
        r_planet = 25269;
        pass_scalar = 2;
end

rp = pass_scalar * r_planet;
%% Calculations
v_planet = sqrt(mu_sun / a_planet); %heliocentric velocity of planet used for pass [km/s]
v_inf = sqrt(v_planet^2 + v_arr^2 - (2*v_planet*v_arr*cosd(fpa_arr))); %hyperbolic velocity around planet [km/s]

%% Conic Values
a_hyp = -mu_planet / (v_inf^2); %semimajor axis of hyperbola
e_hyp = 1 + rp / abs(a_hyp); %eccentricity of hyperbola

delta = 2*asind(1/e_hyp);

etaSin = asind(asind(v_))

b_hyp = abs(a_hyp)*sqrt(e_hyp^2 - 1); %semiminor axis of hyperbola

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

if abs(check1 - v_dep) < 0.5
    beta = beta1;
elseif abs(check2 - v_dep) < 0.5
    beta = beta2;
else
    fprintf('You fucked up\n')
end

alpha = 180 - beta;

% Hyperbolic Pass
eta = 180 - beta - fpa_arr; %arbitrary angle in velocity triangle
delta1 = asind(v_eq / v_inf * sind(eta)); %turn angle
delta2 = 180 - delta1;

% Quadrant Check
check1 = sqrt(v_inf^2 + v_inf^2 - (2*v_inf*v_inf*cosd(delta1)));
check2 = sqrt(v_inf^2 + v_inf^2 - (2*v_inf*v_inf*cosd(delta2)));
if abs(check1 - v_eq) < 0.5
    delta = delta1;
elseif abs(check2 - v_eq) < 0.5
    delta = delta2;
else
    fprintf('You fucked up\n')
end


end
