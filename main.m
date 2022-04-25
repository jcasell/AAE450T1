nx = 7;
ny = 7;
nu = 3;
nlobj = nlmpc(nx, ny, nu);

Ts = 0.025;
% Ts = 1;
nlobj.Ts = Ts;
nlobj.PredictionHorizon = 10;
nlobj.ControlHorizon = 5;

nlobj.Model.StateFcn = 'dynamics';
nlobj.Model.IsContinuousTime = false;

nlobj.Model.OutputFcn = 'output';

nlobj.Weights.OutputVariables = [0, 0, 0, 1/4, 1/4, 1/4, 1/4]; % for pointing
% nlobj.Weights.OutputVariables = [1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7]; % for spin up
nlobj.Weights.ManipulatedVariablesRate = [0.1 .1 .1];

nlobj.MV(1).Min = -20;
nlobj.MV(1).Max = 20;
nlobj.MV(2).Min = -20;
nlobj.MV(2).Max = 20;
nlobj.MV(3).Min = -20;
nlobj.MV(3).Max = 20;

% nlobj.Optimization.CustomCostFcn = 'cost';
mu = 3.986e14;
x0 = [0; 0; 0; 0; sin(pi/3); 0; cos(pi/3)]; % initial states for pointing
% x0 = [0; 0; 0; 0; sin(pi/3); 0; cos(pi/3)]; % initial states for spin up
u0 = [0; 0; 0];
% validateFcns(nlobj,x0,u0,[],{Ts});

EKF = extendedKalmanFilter(@satState, @satMeasurement);

x = [0; 0; 0; -0.8276; 0.2550; -0.4811; 0.1364]; % x for pointing
% x = [0; 0; 0; 0; sin(pi/3); 0; cos(pi/3)]; % x for spin up

y = [x(1);x(2); x(3); x(4); x(5); x(6); x(7)];
EKF.State = x;

mv = [0; 0; 0]; % change if needed
yref1 = [0 0 0 -0.8276    0.2550   -0.4811    0.1364]; % y ref for pointing
% yref2 = [0 0 (.664) -0.5506 0.5435 -0.6318 0.0488]; % y ref for spin up

nloptions = nlmpcmoveopt;
nloptions.Parameters = {Ts};

% simulation
Duration = 10000;
hbar = waitbar(0,'Simulation Progress');
mvHistory = mv;
xHistory = x;
yHistory = y;
for ct = 1:(10000/Ts)
    % Set references
    yref = yref1;
    
    % Correct previous prediction using current measurement.
    xk = correct(EKF, y);
    % Compute optimal control moves.
    [mv,nloptions,info] = nlmpcmove(nlobj,xk,mv,yref,[],nloptions);
    % Predict prediction model states for the next iteration.
    predict(EKF, [mv; Ts]);
    % Implement first optimal control move and update plant states.
    x = satState(x,mv);
    % Generate sensor data with some white noise.
    % y = x([1 2 3 4 5 6 7]) + randn(7,1)*-0.4818e-6; 
    % assume processed noise is basically zero and stick with measurement
    % noise due to sensor
    % y = x([1 2 3 4 5 6 7]) + normrnd(0, 0.001, 7,1); % y for spin up
    y = x([1 2 3 4 5 6 7]) + normrnd(0, 0.0001, 7,1); % y for pointing
    % Save plant states for display.
    xHistory = [xHistory x]; %#ok<*AGROW>
    mvHistory = [mvHistory mv];
    yHistory = [yHistory y];
    waitbar(ct*Ts/10000,hbar);
end
close(hbar)

%% do some plotting for pointing maneuver
% Plot the closed-loop response.
figure
hold on
plot(0:Ts:Duration,mvHistory(1,:), 'b');
plot(0:Ts:Duration,mvHistory(2,:), 'r');
plot(0:Ts:Duration,mvHistory(3,:), 'g');
xlabel('time');
ylabel('Torques (Nm)');
title('Control Torques');
legend('L1', 'L2', 'L3');

figure
hold on
plot(0:Ts:Duration,xHistory(1,:), 'b')
plot(0:Ts:Duration,yHistory(1,:), 'g--')
plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(1), 'r--')
xlabel('time')
ylabel('\omega_1')
title('\omega_1')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(0:Ts:Duration,xHistory(2,:), 'b')
plot(0:Ts:Duration,yHistory(2,:), 'g--')
plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(2), 'r--')
xlabel('time')
ylabel('\omega_2')
title('\omega_2')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(0:Ts:Duration,xHistory(3,:), 'b')
plot(0:Ts:Duration,yHistory(3,:), 'g--')
plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(3), 'r--')
xlabel('time')
ylabel('\omega_3')
title('\omega_3')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(0:Ts:Duration,xHistory(4,:), 'b')
plot(0:Ts:Duration,yHistory(4,:), 'g--')
plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(4), 'r--')
xlabel('time')
ylabel('\epsilon_1')
title('\epsilon_1')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(0:Ts:Duration,xHistory(5,:), 'b')
plot(0:Ts:Duration,yHistory(5,:), 'g--')
plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(5), 'r--')
xlabel('time')
ylabel('\epsilon_2')
title('\epsilon_2')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(0:Ts:Duration,xHistory(6,:), 'b')
plot(0:Ts:Duration,yHistory(6,:), 'g--')
plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(6), 'r--')
xlabel('time')
ylabel('\epsilon_3')
title('\epsilon_3')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(0:Ts:Duration,xHistory(7,:), 'b')
plot(0:Ts:Duration,yHistory(7,:), 'g--')
plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(7), 'r--')
xlabel('time')
ylabel('\epsilon_4')
title('\epsilon_4')
legend('Estimated', 'Measured', 'Reference');

%% do some plotting for spin up maneuver after pointing
% % Plot the closed-loop response.
% figure
% hold on
% plot(0:Ts:Duration,mvHistory(1,:), 'b');
% plot(0:Ts:Duration,mvHistory(2,:), 'r');
% plot(0:Ts:Duration,mvHistory(3,:), 'g');
% xlabel('time');
% ylabel('Torques (Nm)');
% title('Control Torques');
% legend('L1', 'L2', 'L3');
% 
% figure
% hold on
% plot(0:Ts:Duration,xHistory(1,:), 'b')
% % plot(0:Ts:Duration,yHistory(1,:), 'g--')
% plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(1), 'r--')
% xlabel('time')
% ylabel('\omega_1')
% title('\omega_1')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(0:Ts:Duration,xHistory(2,:), 'b')
% % plot(0:Ts:Duration,yHistory(2,:), 'g--')
% plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(2), 'r--')
% xlabel('time')
% ylabel('\omega_2')
% title('\omega_2')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(0:Ts:Duration,xHistory(3,:), 'b')
% % plot(0:Ts:Duration,yHistory(3,:), 'g--')
% plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(3), 'r--')
% xlabel('time')
% ylabel('\omega_3')
% title('\omega_3')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(0:Ts:Duration,xHistory(4,:), 'b')
% % plot(0:Ts:Duration,yHistory(4,:), 'g--')
% plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(4), 'r--')
% xlabel('time')
% ylabel('\epsilon_1')
% title('\epsilon_1')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(0:Ts:Duration,xHistory(5,:), 'b')
% % plot(0:Ts:Duration,yHistory(5,:), 'g--')
% plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(5), 'r--')
% xlabel('time')
% ylabel('\epsilon_2')
% title('\epsilon_2')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(0:Ts:Duration,xHistory(6,:), 'b')
% % plot(0:Ts:Duration,yHistory(6,:), 'g--')
% plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(6), 'r--')
% xlabel('time')
% ylabel('\epsilon_3')
% title('\epsilon_3')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(0:Ts:Duration,xHistory(7,:), 'b')
% % plot(0:Ts:Duration,yHistory(7,:), 'g--')
% plot(0:Ts:Duration,ones(size(xHistory(1, :)))*yref1(7), 'r--')
% xlabel('time')
% ylabel('\epsilon_4')
% title('\epsilon_4')
% legend('Estimated', 'Measured', 'Reference');

% diffEst_1 = mean(xHistory(1, :) - yHistory(1, :));
% diffEst_2 = mean(xHistory(2, :) - yHistory(2, :));
% diffEst_3 = mean(xHistory(3, :) - yHistory(3, :));
% 
% difEst_Omega = mean(diffEst_3, diffEst_2, diffEst_1);
% 
% diffEst_4 = mean(xHistory(4, :) - yHistory(4, :));
% diffEst_5 = mean(xHistory(5, :) - yHistory(5, :));
% diffEst_6 = mean(xHistory(6, :) - yHistory(6, :));
% diffEst_7 = mean(xHistory(7, :) - yHistory(7, :));
% 
% difEst_Omega = mean(diffEst_4, diffEst_5, diffEst_6);



