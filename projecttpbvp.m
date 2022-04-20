function projecttpbvp()
clc 
clear all

t0 = 0;
tf = 1;

solinit = bvpinit(linspace(t0, tf), [.1;.1;.1;.1;.1;1;5]);
options = bvpset('Stats', 'on', 'RelTol', 1e-1);
solution = bvp4c(@BVP_ode_project, @boundary_conditions_project, solinit, options);

I1 = 396.2;
I2 = 1867;
I3 = 1987.8;

J1 = (I3 - I2) / I1;
J2 = (I1 - I3)/I2;
J3 = (I2 - I1)/I3;

y = solution.y;
t = solution.x;
t = linspace(0, 20, 854);

w1 = y(1,:);
w2 = y(2,:);
w3 = y(3,:);

lambda1 = y(4,:);
lambda2 = y(5,:);
lambda3 = y(6,:);

L1 = -lambda1 / I1;
L2 = -lambda2 / I2;
L3 = -lambda3 / I3;

hold on
plot(t, w1, 'b');
plot(t, w2, 'r');
plot(t, w3, 'g');
title('Angular Velocity Time Histories');
xlabel('time (s)');
ylabel('omega (rad/s)');
legend('w1', 'w2', 'w3');

figure
hold on

plot(t, lambda1, 'b--');
plot(t, lambda2, 'r--');
plot(t, lambda3, 'g--');
title('Costate Time Histories');
xlabel('time (s)');
ylabel('Costates');
legend('Lambda 1', 'Lambda 2', 'Lambda 3');

figure;
hold on
plot(t, L1 / 20, 'b');
plot(t, L2 / 20, 'r');
plot(t, L3 / 20, 'g');
title('Time Histories');
xlabel('time (s)');
ylabel('Control Torques (Nm)');
legend('L1', 'L2', 'L3');

hold off

r1 = [0, -J1*w3(end), -J1*w2(end), -1/(I1^2), 0, 0];
r2 = [-J2*w3(end), 0, -J2*w1(end), 0, -1/(I2^2), 0];
r3 = [-J3*w2(end), -J3*w1(end), 0, 0, 0, -1/(I3^2)];
r4 = [0, J3*lambda3(end), J2*lambda2(end), 0, J2*w3(end), J3*w2(end)];
r5 = [J3*lambda3(end), 0, J1*lambda1(end), J1*w3(end), 0, J3*w1(end)];
r6 = [J2*lambda2(end), J1*lambda1(end), 0, J1*w2(end), J2*w1(end), 0];

A = [r1; r2; r3; r4; r5; r6];
% B = [L1(end); L2(end); L3(end); -lambda1(end) / I1; -lambda2(end) / I2; -lambda3(end) / I3];
B = [1/(I1^2); 1/(I2^2); 1/(I3^2); 0; 0; 0];
Q = eye(6);
R = 1;

% find controller gains
[K, S, e] = lqr(A, B, Q, R);

t_span = linspace(0, 10, 500); 
q_inits = [0, 0, 5, 0, 0, 0];
options = odeset('RelTol', 1e-12, 'AbsTol', 1e-12);
[t,qq] = ode45(@eom_lqr, t_span, q_inits, options);
omega_1 = qq(:, 1);
omega_2 = qq(:, 2);
omega_3 = qq(:, 3);

figure;
hold on;
plot(t, omega_1, 'b');
plot(t, omega_2, 'r');
plot(t, omega_3, 'g');
title('LQR Controlled Rotation Rates for SHAC');
xlabel('time (s)');
ylabel('angular velocity (rad/s)');


function xdot = eom_lqr(t, xinits)
    qdot_Inits = xinits;
    sys = A;
    sys_b = B;


    % the EOM
    q_dot = (sys - sys_b * K) * qdot_Inits;

    xdot = [q_dot];
end
end








