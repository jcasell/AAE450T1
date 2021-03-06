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
time_step = time_sec(end) / 2^14;
%Find the change in angle of B-1 Axis
first_axis_vec_0 = [first_axis_unit(1,1); first_axis_unit(2,1); first_axis_unit(3,1)];
for k = 1:(length(tspan)-1)
    first_axis_vec(:,k) = [first_axis_unit(1,k); first_axis_unit(2,k); first_axis_unit(3,k)];
    first_axis_vec_next(:,k) = [first_axis_unit(1,k+1); first_axis_unit(2,k+1); first_axis_unit(3,k+1)];
    b1_anglediff_step(k) = acosd(dot(first_axis_vec(:,k),first_axis_vec_next(:,k)) / (norm(first_axis_vec(:,k)) * norm(first_axis_vec(:,k))));
    b1_anglediff(k) = acosd(dot(first_axis_vec(:,k),first_axis_vec_0) / (norm(first_axis_vec(:,k)) * norm(first_axis_vec_0)));
    ang_rate(k) = deg2rad(b1_anglediff_step(k)) / (k * (time_sec(end) / length(tspan)));
end


%Create the C-Frame
omega_spin = 4 * (2*pi) / 60;
for k=1:length(tspan)
    c_1_axis(:,k) = first_axis_unit(:,k);
    c_2_axis(:,k) = cos(omega_spin * k * (time_sec(end) / length(tspan))) * second_axis_unit(:,k) - sin(omega_spin * k * (time_sec(end) / length(tspan))) * third_axis_unit(:,k); 
    c_3_axis(:,k) = cos(omega_spin * k * (time_sec(end) / length(tspan))) * third_axis_unit(:,k) + sin(omega_spin * k * (time_sec(end) / length(tspan))) * second_axis_unit(:,k);
    
end



%Find the Amount of Times to Thrust Ideally, where 0.05 degrees is pointing
%error requirement 
avg_angle_rate = deg2rad(max(b1_anglediff)) / time_sec(end);
I_estimation = 750;
avg_ang_momentum = I_estimation * avg_angle_rate;
delta_V = (4.75 / (2*pi)) *(avg_angle_rate) * time_step * time_sec(end);
t_accel = avg_ang_momentum * (1 * 0.8);


ideal_thrust_number = (max(b1_anglediff) / 0.05) / 2;
ideal_thrust_number_rate = ideal_thrust_number / (time_sec(end) / 3600); %Per Hour

t_total = t_accel * ideal_thrust_number;
% mass_prop =  (t_total * 1)/(9.8*227);

time_change = time_sec(end) / length(tspan);
for k = 1:(length(tspan)-2)
    ang_accel(k) = (b1_anglediff_step(k+1) - b1_anglediff_step(k)) / time_change;
end

avg_ang_accel = deg2rad(mean(ang_accel));
Torque_est = avg_ang_accel * I_estimation;
length_arm = 0.8;
f_req = Torque_est / length_arm;
f_total = f_req * time_sec(end);
time_thrusting = ideal_thrust_number * 10;
mass_prop = (abs(f_total) * time_thrusting) / (227*9.8)
%Plot the angle difference over whole time span
figure(1)
plot(tspan(1:end-1) / (3600 * 24 * 365), (b1_anglediff_step), 'LineWidth', 2)
grid on;
xlabel("Time in Years")
ylabel("Angle Difference (deg)");
title("Change in Angle of C-1 Axis for Each Quarter Day Time Step")
%xlim([0 1])

figure(2)
plot(tspan(1:end-1)/(3600 * 24 * 365), (b1_anglediff), 'LineWidth', 2)
grid on;
xlabel("Time in Years")
ylabel("Angle Difference (deg)");
title("Change in Angle of C-1 Axis Compared to Initial Time in Orbit")
%xlim([0 1])

% Plot the change in the body frame with respect to the heliocentric ICRF
% frame 

% spin_sim = figure(3);
% spin_sim.Color = 'black';
% hold on;
% set(gca,'Color',[0,0,0], 'FontSize',16)
% set(gca,'XColor',[1,1,1])
% set(gca,'YColor',[1,1,1])
% set(gca,'ZColor',[1,1,1])
% a = quiver3(0,0,0,c_1_axis(1,1),c_1_axis(2,1),c_1_axis(3,1),'g');
% a.LineWidth = 2;
% a.AutoScale= 'off';
% b = quiver3(0,0,0,c_2_axis(1,1),c_2_axis(2,1),c_2_axis(3,1),'r');
% b.LineWidth = 2;
% b.AutoScale= 'off';
% c = quiver3(0,0,0,c_3_axis(1,1),c_3_axis(2,1),c_3_axis(3,1),'b');
% c.LineWidth = 2;
% c.AutoScale= 'off';
% d = quiver3(0,0,0,1,0,0,'m'); 
% d.LineWidth = 2;
% d.AutoScale= 'off';
% e = quiver3(0,0,0,0,1,0,'c'); 
% e.LineWidth = 2;
% e.AutoScale= 'off';
% f = quiver3(0,0,0,0,0,1,'y');
% f.LineWidth = 2;
% f.AutoScale= 'off';
% 
% text(1, 0.1, 0, "ICRF X-Axis", 'Color', 'white', 'FontSize', 16);
% text(0.1, 1, 0, "ICRF Y-Axis", 'Color', 'white', 'FontSize', 16);
% text(0, 0.1, 1, "ICRF Z-Axis", 'Color', 'white', 'FontSize', 16);
% xlabel("ICRF-X-Direction", 'FontSize', 16);
% ylabel("ICRF-Y-Direction", 'FontSize', 16);
% zlabel("ICRF-Z-Direction", 'FontSize', 16);
% sim_title = title("Change in Spinning Body Frame w.r.t. ICRF Over Time");
% sim_title.Color = 'white';
% sim_title.FontSize = 18;
% sim_leg = legend('\color{white} C-1 Axis', '\color{white} C-2 Axis', '\color{white} C-3 Axis', '\color{white} ICRF X', '\color{white} ICRF Y', '\color{white} ICRF Z', "location", "best");
% sim_leg.Title.Color = 'white';
% sim_leg.FontSize = 16;
% grid on;
% view(3);
% xlim([-1 1]);
% ylim([-1 1]);
% zlim([-1 1]);
% 
% pause(15)
% 
% for k = 1:length(tspan)
%     aU = c_1_axis(1,k); 
%     aV = c_1_axis(2,k); 
%     aW = c_1_axis(3,k);
%     bU = c_2_axis(1,k); 
%     bV = c_2_axis(2,k); 
%     bW = c_2_axis(3,k);
%     cU = c_3_axis(1,k); 
%     cV = c_3_axis(2,k); 
%     cW = c_3_axis(3,k);
%     
%     txt_b1(k) = text(1.1*c_1_axis(1,k), 1.1*c_1_axis(2,k),1.1*c_1_axis(3,k), "C-1 Axis", 'Color', 'white');
%     txt_b1(k).FontSize = 16;
%     txt_b2(k) = text(1.1*c_2_axis(1,k), 1.1*c_2_axis(2,k),1.1*c_2_axis(3,k), "C-2 Axis", 'Color', 'white');
%     txt_b2(k).FontSize = 16;
%     txt_b3(k) = text(1.1*c_3_axis(1,k), 1.1*c_3_axis(2,k),1.1*c_3_axis(3,k), "C-3 Axis", 'Color', 'white');
%     txt_b3(k).FontSize = 16;
%     current_time_day(k) = k * (time_sec(end) / length(tspan)) / (3600 * 24);
%     time_print = sprintf('Time Elapsed in Days: %.1f', current_time_day(k));
%     txt_time(k) = text(-0.4, 0, -0.5, time_print);
%     txt_time(k).FontSize = 18;
%     txt_time(k).FontWeight = 'Bold';
%     txt_time(k).Color = 'white';
%     
% 
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
%     pause(0.75)
%     delete(txt_b1(k));
%     delete(txt_b2(k));
%     delete(txt_b3(k));
%     delete(txt_time(k));
%     
%    
% 
% end
% 
