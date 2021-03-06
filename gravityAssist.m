function [v_dep,fpa_dep,dv_eq_vec] = gravityAssist(planet_name,v_arr,fpa_arr)
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
        pass_scalar = 32;
    case "Saturn"
        a_planet = 1427387908;
        mu_planet = 37940626.0611;
        r_planet = 60268;
        pass_scalar = 10;
    case "Mars"
        a_planet = 227987000;
        mu_planet = 42828;
        r_planet = 3396.2;
        pass_scalar = 1.1;
end

rp = pass_scalar * r_planet;
%% Calculations
v_arr_vec = [v_arr * sind(fpa_arr), v_arr * cosd(fpa_arr)];
v_planet = sqrt(mu_sun / a_planet); %heliocentric velocity of planet used for pass [km/s]
% v_inf = sqrt(v_planet^2 + v_arr^2 - (2*v_planet*v_arr*cosd(fpa_arr))); %hyperbolic velocity around planet [km/s]
v_inf_minus = v_arr_vec - [0,v_planet]; %arrival v infinity vector
v_inf = norm(v_inf_minus);


%% Conic Values
%New Vector Math
a_hyp = -mu_planet / (v_inf^2); %semimajor axis of hyperbola
e_hyp = 1 + rp / abs(a_hyp); %eccentricity of hyperbola

psi = atan2d(v_inf_minus(1),v_inf_minus(2)); %Arbitrary angle for calculations
delta = 2*asind(1/e_hyp); %turn angle

v_inf_plus = [v_inf * sind(psi - delta), v_inf * cosd(psi - delta)]; %departure v infinity vector
v_dep_vec = v_inf_plus + [0,v_planet]; %departure velocity vector 
v_dep = norm(v_dep_vec);

fpa_dep = asind((v_inf/v_dep)*sind(180 - (psi-delta))); %departure flight path angle
dv_eq_vec = v_dep_vec - v_arr_vec; %equivalent deltaV from pass
dv_eq = norm(dv_eq_vec);

beta1 = asind(v_dep*sind(fpa_dep - fpa_arr)/dv_eq);
beta2 = 180 - beta1;

% Quadrant Check
check1 = sqrt(dv_eq^2 + v_arr^2 - (2*dv_eq*v_arr*cosd(beta1)));
check2 = sqrt(dv_eq^2 + v_arr^2 - (2*dv_eq*v_arr*cosd(beta2)));

if abs(check1 - v_dep) < 0.5
    beta = beta1;
elseif abs(check2 - v_dep) < 0.5
    beta = beta2;
else
    fprintf('You fucked up\n')
end

alpha = 180 - beta; %heliocentric velocity turn angle

%Old Vector Math
%{
v_planet = sqrt(mu_sun / a_planet); %heliocentric velocity of planet used for pass [km/s]
v_inf = sqrt(v_planet^2 + v_arr^2 - (2*v_planet*v_arr*cosd(fpa_arr))); %hyperbolic velocity around planet [km/s]

v_arr = [v_arr * sind(fpa_arr), v_arr * cosd(fpa_arr)];
%% Conic Values
a_hyp = -mu_planet / (v_inf^2); %semimajor axis of hyperbola
e_hyp = 1 + rp / abs(a_hyp); %eccentricity of hyperbola

psi = atan2d(v_arr(1),v_arr(2));
delta = 2*asind(1/e_hyp);

v_dep_vec = [v_inf * sind(psi - delta), v_inf * cosd(psi - delta)];
fpa_dep = atan2d(v_dep_vec(1),v_dep_vec(2));
v_dep = norm(v_dep_vec);
%}

%{
b_hyp = abs(a_hyp)*sqrt(e_hyp^2 - 1); %semiminor axis of hyperbola

% Departure
%v_dep = v_planet + v_inf; %departure velocity [km/s]
%fpa_dep = 0; %departure flight path angle [deg]

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
%}

end
