clear;
clc;
close all;


%Inputs of Trajectory of Spacecraft
Heliocentric_ICRF_table_values = readtable('HeliocentricInfo.txt');
time_days = table2array(Heliocentric_ICRF_table_values(:,9));
time_sec = time_days * 24 * 3600;
ICRF_x_sc = table2array(Heliocentric_ICRF_table_values(:,1));
ICRF_y_sc = table2array(Heliocentric_ICRF_table_values(:,2));
ICRF_z_sc = table2array(Heliocentric_ICRF_table_values(:,3));

%Spacecraft Time and Position Update (Interpolation)
new_time_sc = linspace(0, time_sec(end), 2^14);
ICRF_x_sc_interp = interp1(time_sec, ICRF_x_sc, new_time_sc);
ICRF_y_sc_interp = interp1(time_sec, ICRF_y_sc, new_time_sc);
ICRF_z_sc_interp = interp1(time_sec, ICRF_z_sc, new_time_sc);

%Get Inputs of Earth Trajectory
%Earth Time and Position Update
start_time_earth = juliandate(2031,3,1,12,0,0);
end_time_earth = start_time_earth + time_days(end);
tspan_earth = linspace(start_time_earth, end_time_earth, length(time_days)); %in Julian Days
earth_pos = load('earth_pos_2.mat');
ICRF_x_earth = earth_pos.earth_pos(1,:);
ICRF_y_earth = earth_pos.earth_pos(2,:);
ICRF_z_earth = earth_pos.earth_pos(3,:);

%Earth Time and Position Update (Interpolation)
new_time_earth = linspace(start_time_earth, end_time_earth, 2^14);
ICRF_x_earth_interp = interp1(time_sec, ICRF_x_earth, new_time_earth);
ICRF_y_earth_interp = interp1(time_sec, ICRF_y_earth, new_time_earth);
ICRF_z_earth_interp = interp1(time_sec, ICRF_z_earth, new_time_earth);

%Use this as FINAL time vec
tspan = new_time_sc;
%Find the Basis Vectors in the Body Frame

for k = 1:length(tspan)
    %Find the S/C to Earth Vec, use this as first axis direction
    sc_earth_pos(:,k) = [ICRF_x_earth_interp(k) - ICRF_x_sc_interp(k); ICRF_y_earth_interp(k) - ICRF_y_sc_interp(k); ICRF_z_earth_interp(k)- ICRF_z_sc_interp(k)];
    
    %Find the Sun to S/C vector, use this to define the third axis 
    sc_sun_pos(:,k) = [ICRF_x_sc_interp(k); ICRF_y_sc_interp(k); ICRF_z_sc_interp(k)];
    third_axis_cross(:,k) = cross(sc_earth_pos(:,k),sc_sun_pos(:,k));
    
    %Find the third axis unit vectors
    third_axis_unit(:,k) = third_axis_cross(:,k) / norm(third_axis_cross(:,k));
    
    %Define the second axis with the first and third axis
    second_axis_cross(:,k) = cross(third_axis_cross(:,k), sc_earth_pos(:,k));
    
    %Find the second axis unit vectors
    second_axis_unit(:,k) = second_axis_cross(:,k) / norm(second_axis_cross(:,k));
    
    %Find the first axis unit vectors
    first_axis_unit(:,k) = sc_earth_pos(:,k) / norm(sc_earth_pos(:,k));
end

%Find the change in angle of B-1 Axis
first_axis_vec_0 = [first_axis_unit(1,1); first_axis_unit(2,1); first_axis_unit(3,1)];
for k = 1:(length(tspan)-1)
    first_axis_vec(:,k) = [first_axis_unit(1,k); first_axis_unit(2,k); first_axis_unit(3,k)];
    first_axis_vec_next(:,k) = [first_axis_unit(1,k+1); first_axis_unit(2,k+1); first_axis_unit(3,k+1)];
    b1_anglediff_step(k) = acosd(dot(first_axis_vec(:,k),first_axis_vec_next(:,k)) / (norm(first_axis_vec(:,k)) * norm(first_axis_vec(:,k))));
    b1_anglediff(k) = acosd(dot(first_axis_vec(:,k),first_axis_vec_0) / (norm(first_axis_vec(:,k)) * norm(first_axis_vec_0)));
end

%Find the Amount of Times to Thrust Ideally, where 0.05 degrees is pointing
%error requirement 
ideal_thrust_number = (max(b1_anglediff) / 0.05);
ideal_thrust_number_rate = ideal_thrust_number / (time_sec(end) / 3600 / 24); %Per Hour

%Plot the angle difference over whole time span
figure(1)
plot(tspan(1:end-1), (b1_anglediff_step))
grid on;
xlabel("Time (s)")
ylabel("Angle Difference (deg)");
title("Angle Difference in B-1 Axis for 0.26 Day Time Step")

figure(2)
plot(tspan(1:end-1), (b1_anglediff))
grid on;
xlabel("Time (s)")
ylabel("Angle Difference (deg)");
title("Angle Difference in B-1 Axis Compared to First Time in Orbit")

% Plot the change in the body frame with respect to the heliocentric ICRF
% frame 

% figure(3)
% hold on;
% 
% a = quiver3(0,0,0,first_axis_unit(1,1),first_axis_unit(2,1),first_axis_unit(3,1),'g');
% b = quiver3(0,0,0,second_axis_unit(1,1),second_axis_unit(2,1),second_axis_unit(3,1),'r');
% c = quiver3(0,0,0,third_axis_unit(1,1),third_axis_unit(2,1),third_axis_unit(3,1),'b');
% quiver3(0,0,0,1,0,0,'m'); quiver3(0,0,0,0,1,0,'k'); quiver3(0,0,0,0,0,1,'y');
% text(1, 0, 0, "ICRF X-Axis");
% text(0, 1, 0, "ICRF Y-Axis");
% text(0, 0, 1, "ICRF Z-Axis");
% xlabel("ICRF-X-Direction");
% ylabel("ICRF-Y-Direction");
% zlabel("ICRF-Z-Direction");
% title("Change in Body Reference Frame w.r.t ICRF Over Time")
% legend("B-1 Axis", "B-2 Axis", "B-3 Axis", "ICRF X", "ICRF Y", "ICRF Z", "location", "best")
% grid on;
% 
% for k = 1:length(tspan)
%     aU = first_axis_unit(1,k); 
%     aV = first_axis_unit(2,k); 
%     aW = first_axis_unit(3,k);
%     bU = second_axis_unit(1,k); 
%     bV = second_axis_unit(2,k); 
%     bW = second_axis_unit(3,k);
%     cU = third_axis_unit(1,k); 
%     cV = third_axis_unit(2,k); 
%     cW = third_axis_unit(3,k);
%     
%     txt_b1(k) = text(first_axis_unit(1,k), first_axis_unit(2,k),first_axis_unit(3,k), "B-1 Axis");
%     txt_b2(k) = text(second_axis_unit(1,k), second_axis_unit(2,k),second_axis_unit(3,k), "B-2 Axis");
%     txt_b3(k) = text(third_axis_unit(1,k), third_axis_unit(2,k),third_axis_unit(3,k), "B-3 Axis");
%     
%     a.UData = aU; 
%     a.VData = aV; 
%     a.WData = aW;
%     b.UData = bU; 
%     b.VData = bV; 
%     b.WData = bW;
%     c.UData = cU; 
%     c.VData = cV; 
%     c.WData = cW;
%     pause(0.002)
%     delete(txt_b1(k));
%     delete(txt_b2(k));
%     delete(txt_b3(k));
% 
% end
% 