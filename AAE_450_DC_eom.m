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
time_days = table2array(ICRF_table_values(:,4));
true_anom = table2array(ICRF_table_values(:,3));
inc = table2array(ICRF_table_values(:,2));
aop = table2array(ICRF_table_values(:,1));
time_sec = time_days * 24 * 3600;
long_asc = aop + true_anom;

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


