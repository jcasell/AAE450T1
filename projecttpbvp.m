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

y = solution.y;
t = solution.x;

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
plot(t, L1, 'b');
plot(t, L2, 'r');
plot(t, L3, 'g');
title('Time Histories');
xlabel('time (s)');
ylabel('Control Torques (Nm)');
legend('L1', 'L2', 'L3');

hold off


