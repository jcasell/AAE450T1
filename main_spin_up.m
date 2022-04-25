nx = 7;
ny = 7;
nu = 3;
nlobj = nlmpc(nx, ny, nu);

Ts = 0.025;
nlobj.Ts = Ts;
nlobj.PredictionHorizon = 10;
nlobj.ControlHorizon = 5;

nlobj.Model.StateFcn = 'dynamics';
nlobj.Model.IsContinuousTime = false;

nlobj.Model.OutputFcn = 'output';

% nlobj.Weights.OutputVariables = [1/14, 1/14, 1/14, 3/14, 3/14, 3/14, 3/14];
nlobj.Weights.OutputVariables = [1/7, 1/7, 1/7, 1/7, 1/7, 1/7, 1/7]; % for spin up
nlobj.Weights.ManipulatedVariablesRate = [.1 .1 .1];

nlobj.MV(1).Min = -20;
nlobj.MV(1).Max = 20;
nlobj.MV(2).Min = -20;
nlobj.MV(2).Max = 20;
nlobj.MV(3).Min = -20;
nlobj.MV(3).Max = 20;

% nlobj.Optimization.CustomCostFcn = 'cost';
mu = 3.986e14;
x0 = [0; 0; 0; 0; sin(pi/3); 0; cos(pi/3)]; % initial states for spin up
u0 = [0; 0; 0];
% validateFcns(nlobj,x0,u0,[],{Ts});

EKF = extendedKalmanFilter(@satState, @satMeasurement);

x = [0; 0; 0; 0; sin(pi/3); 0; cos(pi/3)]; % x for spin up

y = [x(1);x(2); x(3); x(4); x(5); x(6); x(7)];
EKF.State = x;

mv = [0; 0; 0]; % change if needed
yref2 = [0 0 (.664) -0.5506 0.5435 -0.6318 0.0488]; % y ref for spin up
% yref2 = [0 0 (.664) 0 sin(pi/3) 0 cos(pi/3)]; % y ref for spin up maintianing attitude
yref = [0 0 (.5236) 0 sin(pi/3) 0 cos(pi/3)]; 

nloptions = nlmpcmoveopt;
nloptions.Parameters = {Ts};

% simulation
Duration = 20;
hbar = waitbar(0,'Simulation Progress');
mvHistory = mv;
xHistory = x;
yHistory = y;
for ct = 1:(20/Ts)
    % Set references
    yref = yref2;
    
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
    y = x([1 2 3 4 5 6 7]) + normrnd(0, 0.001, 7,1); % y for spin up
   
    % Save plant states for display.
    xHistory = [xHistory x]; 
    mvHistory = [mvHistory mv];
    yHistory = [yHistory y];
    waitbar(ct*Ts/20,hbar);
end
close(hbar)

%% do some plotting for spin up maneuver after pointing
% Plot the closed-loop response.
last = 801;
time = 0:Ts:Duration;

figure
hold on
plot(time,mvHistory(1,1:last), 'b');
plot(time,mvHistory(2,1:last), 'r');
plot(time,mvHistory(3,1:last), 'g');
xlabel('time');
ylabel('Torques (Nm)');
title('Control Torques');
legend('L1', 'L2', 'L3');

figure
hold on
plot(time,xHistory(1,1:last), 'b')
plot(time,yHistory(1,1:last), 'g--')
plot(time,ones(size(xHistory(1, 1:last)))*yref(1), 'r--')
xlabel('time (s)')
ylabel('\omega_1 (rad/s)')
title('\omega_1')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(time,xHistory(2,1:last), 'b')
plot(time,yHistory(2,1:last), 'g--')
plot(time,ones(size(xHistory(1, 1:last)))*yref(2), 'r--')
xlabel('time (s)')
ylabel('\omega_2 (rad/s)')
title('\omega_2')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(time,xHistory(3,1:last), 'b')
plot(time,yHistory(3,1:last), 'g--')
plot(time,ones(size(xHistory(1, 1:last)))*.704, 'r--')
xlabel('time (s)')
ylabel('\omega_3 (rad/s)')
title('\omega_3')
legend('Estimated', 'Measured', 'Reference');

% normalize the euler angles
normed_x = zeros(4, last);
normed_y = zeros(4, last);

for i = 1:last
    vec_x = [xHistory(4, i); xHistory(5, i); xHistory(6, i); xHistory(7, i)];
    % normed_x(:, i) = vec_x./sum(abs(vec_x));
    normed_x(:, i) = normalize(vec_x);

    vec_y = [yHistory(4, i); yHistory(5, i); yHistory(6, i); yHistory(7, i)];
    % normed_y(:, i) = vec_y./sum(vec_y);
    normed_y(:, i) = normalize(vec_y);
end

figure
hold on
plot(time,normed_x(1,1:last), 'b')
plot(time,normed_y(1,1:last), 'g--')
plot(time,ones(size(xHistory(1, 1:last)))*yref(4), 'r--')
xlabel('time (s)')
ylabel('\epsilon_1')
title('\epsilon_1')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(time,normed_x(2,1:last), 'b')
plot(time,normed_y(2,1:last), 'g--')
plot(time,ones(size(xHistory(1, 1:last)))*yref(5), 'r--')
xlabel('time')
ylabel('\epsilon_2')
title('\epsilon_2')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(time,normed_x(3,1:last), 'b')
plot(time,normed_y(3,1:last), 'g--')
plot(time,ones(size(xHistory(1, 1:last)))*yref(6), 'r--')
xlabel('time')
ylabel('\epsilon_3')
title('\epsilon_3')
legend('Estimated', 'Measured', 'Reference');

figure
hold on
plot(time,normed_x(4,1:last), 'b')
plot(time,normed_y(4,1:last), 'g--')
plot(time,ones(size(xHistory(1, 1:last)))*yref(7), 'r--')
xlabel('time')
ylabel('\epsilon_4')
title('\epsilon_4')
legend('Estimated', 'Measured', 'Reference');

% figure
% hold on
% plot(time,xHistory(4,1:last), 'b')
% plot(time,yHistory(4,1:last), 'g--')
% plot(time,ones(size(xHistory(1, 1:last)))*yref(4), 'r--')
% xlabel('time (s)')
% ylabel('\epsilon_1 (rad/s)')
% title('\epsilon_1')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(time,xHistory(5,1:last), 'b')
% plot(time,yHistory(5,1:last), 'g--')
% plot(time,ones(size(xHistory(1, 1:last)))*yref(5), 'r--')
% xlabel('time')
% ylabel('\epsilon_2')
% title('\epsilon_2')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(time,xHistory(6,1:last), 'b')
% plot(time,yHistory(6,1:last), 'g--')
% plot(time,ones(size(xHistory(1, 1:last)))*yref(6), 'r--')
% xlabel('time')
% ylabel('\epsilon_3')
% title('\epsilon_3')
% legend('Estimated', 'Measured', 'Reference');
% 
% figure
% hold on
% plot(time,xHistory(7,1:last), 'b')
% plot(time,yHistory(7,1:last), 'g--')
% plot(time,ones(size(xHistory(1, 1:last)))*yref(7), 'r--')
% xlabel('time')
% ylabel('\epsilon_4')
% title('\epsilon_4')
% legend('Estimated', 'Measured', 'Reference');
