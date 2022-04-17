clear;
clc;
close all;

%Step 1: Inputs From Trajectory
% --> Get Initial Angles After LEO in the Heliocentric Reference Frame
%(Longitude of Ascending Node, Inclination, Argument of Periapsis)
% --> Get Initial Angles After Jupiter in the Heliocentric Reference Frame
%(Longitude of Ascending Node, Inclination, Argument of Periapsis)
%Get Velocity Values From Trajectory (not sure about this input currently)
ICRF_table_values = readtable('ICRFOrbitChars.txt');
time_days = table2array(ICRF_table_values(:,6));
ICRF_RMAG = table2array(ICRF_table_values(:,5));
long_asc = table2array(ICRF_table_values(:,4));
true_anom = table2array(ICRF_table_values(:,3));
inc = table2array(ICRF_table_values(:,2));
aop = table2array(ICRF_table_values(:,1));
time_sec = time_days * 24 * 3600;


inc = deg2rad(inc);
aop = deg2rad(aop);
long_asc = deg2rad(long_asc);

%data in degrees 
%long = arg_peri + true anomaly

%Step 2: Define Our LEO and Jupiter Euler Parameters
%Use 3-1-3 Sequence to Define EPs of Spacecraft 
%(long_asc, inc, aop) will be the notation of angles
%Assume Heliocentric Fame is Inertial (Denote Inertial to Body [BN])

BN_EP = zeros(4, length(time_sec));
for k = 1:length(time_sec)
   BN_DCM_temp = EA313toDCM(long_asc(k), inc(k), aop(k));
   ICRF_x_hat(k) = sum(BN_DCM_temp(1,:));
   ICRF_y_hat(k) = sum(BN_DCM_temp(2,:));
   ICRF_z_hat(k) = sum(BN_DCM_temp(3,:));
   ICRF_x_pos(k) = ICRF_x_hat(k) * ICRF_RMAG(k); 
   ICRF_y_pos(k) = ICRF_y_hat(k) * ICRF_RMAG(k); 
   ICRF_z_pos(k) = ICRF_z_hat(k) * ICRF_RMAG(k); 
   BN_EP(:,k) = DCMtoEP(BN_DCM_temp);
end




%Step 3
%Define the Spacecraft Body System
%Define Body Reference Frame (denote B-frame)
%--> Define System where 1st or 3rd (2nd is unstable) axis is direction of spin
%--> Assign S/C Principal Moments of Inertia (I_1, I_2, I_3) where 
%I_1 < I_2 < I_3
%--> Assign an appropriate spin velocity for S/C (omega_s) in B-frame
%--> Define a new reference frame C after rotation of omega_s
%--> Use ODE 45 to find EP history of [CB]
%--> Add EP from [CB] to EP from [BN] to have EP history of [CN]

I_c = [1986, 0, 54; 0, 1867, 0; 54, 0, 398];
eig_value_I_c = eig(I_c);
I_temp = sort(eig_value_I_c);
I_1 = I_temp(1);
I_2 = I_temp(2);
I_3 = I_temp(3);
I_c_B = diag([I_1, I_2, I_3]);
omega_s = 5*(1/60)*2*pi; %use the third axis 


%Step 4 
%Use PID Controller To Control S/C Attidude for Disturbance Torques
%--> Implement EOMs for External Torque on S/C
%--> Integrate Disturbance Torque to find change in orientation
%--> Implement PID Controller to Bring S/C Attitude back to desired
%orientation after Torque Disturbance (want minimal error)
%Use PID Controller To Control S/C Attidude for Despin Maneuver
%--> Implement EOMs for Despin Maneuver on S/C
%--> Integrate Despin Torques to find change in orientation
%--> Implement PID Controller to Bring S/C Attitude to the desired
%orientation for Despin Maneuver

%% disturbance torques
mu_earth = 3.986004418e14;
mu_Jup = 1.26686534e17;
r_Jup = 7.1492e7; % radius of Jupiter in m
r_earth = 6371000; 

% TODO: get actual end time AND radius AND theta (earth and Jupiter)
t_endEarth = 86400; % near earth for 1 days (seconds)
t_endJup = 86400; % near jupiter for 1 days (seconds)
t_nearEarth = linspace(1:t_endEarth, 1000); 
t_nearJup = linspace(1:t_endJup, 1000); 

r_Earth = linspace(1, 100*r_Earth, 1000);
r_Jup = linspace(1, 100*r_Jup, 1000); % r is time history of orbit radius from Jup to SC

theta_Earth = linspace(1:t_endEarth, 1000);
theta_Jup = linspace(1:t_endJup, 1000); % angle bt local vertical and SC principle axis

% assume all torques are scalars (will be max value)
% gradity gradient disturbance torque
Tg_Earth = (3*mu_Earth / (2*r_Earth^3)) * abs(I3 - I2) * sin(2*theta_Earth);
Tg_Jup = (3*mu_Jup / (2*r_Jup^3)) * abs(I3 - I2) * sin(2*theta_Jup); % gravity gradiant near Jupiter
Tg_else = 0; % assume zero since not close to planet

% magnetic field disturbance torque
M_earth = 7.96e15; % earth's magnetic moment 
M_Jup = 2.83e20; % Jupiter's magnetic moment
B_Jup = M_Jup / (r_Jup^2);

% sc dipole source: https://commons.erau.edu/cgi/viewcontent.cgi?article=2705&context=space-congress-proceedings
sc_dipole = 4.2 * (0.0001/ (3.335641e-10)); % Ampere*m^2
Tm_Jup = sc_dipole * B_Jup;
Tm_Earth = 40e-9; % from https://ntrs.nasa.gov/api/citations/19690020961/downloads/19690020961.pdf
Tm_else = 0; % assume zeros since not close to planet

% aerodynamic disturbance torque
Ta_Earth = 0; % assume 0 since little time and far away for all
Ta_Jup = 0;
Ta_else = 0;

% solar radiation pressure disturbance torque
% ref: https://www.pveducation.org/pvcdrom/properties-of-sunlight/solar-radiation-in-space
% TODO: get better cmcp distance and area of illuminated surface
sc_rcmcp = 1; % assume center of pressure is 1m away from center of mass (worst case)
sc_As = 1; % area of illuminated surface of SC
q = .8; % reflectance factor for aluminum
psi_earth = 1367; % solar flux density at earth
psi_Jup = 50.5; % use to check psi as fcn of time
psi_else = 1367;

% find solar flux density as function of AU
% TODO: get vector of radius of SC to sun
R_sun = 695e6; % radius of sun
H_sun = 64e6; % W/m^2 radiant solar intensity at Sun surface
D = linspace(150e9, 6000e9, 1000); % distance from sun to SC (earth to Pluto for now)
psi = ((R_sun^2) / (D^2)) * H_sun;

% TODO: find sun incidence angle over time
i = linspace(0, pi/2, 1000);
c = 3e8; % speed of light
F_sp_earth = (psi / c) * sc_As * (1 + q) * cos(i);

Tsp_ = sc_rcmcp * F_sp_earth;

%%  integration
% state = [w1, w2, w3, 
IC = [0, 0, .15, -.5];

t_span = linspace(0, 60, 500); % 60 second simulation
q_inits = IC;
options = odeset('RelTol', 1e-12, 'AbsTol', 1e-12);
[tt,qq] = ode45('eom_attitude', t_span, q_inits, options);

