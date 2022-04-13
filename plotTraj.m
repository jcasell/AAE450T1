%% Plot Trajectory Function
% This function will plot the trajectory of the spacecraft given the XYZ
% coordinates
% Author: Conner Phillips
%% Calculations

% Read File/Assign Variables
shacCoords = readmatrix('SHACCoords.txt');

SHACX = shacCoords(:,1); % km
SHACY = shacCoords(:,2); % km
SHACZ = shacCoords(:,3); %km 

% Earth and Jupiter Positions
load('earthPos.mat') % km
load('jupPos.mat') % km

% Plot
figure(1)
plot3(SHACX,SHACY,SHACZ)
hold on
plot3(earthPos(1,:),earthPos(2,:),earthPos(3,:))
plot3(jupPos(1,:),jupPos(2,:),jupPos(3,:))
title('Sun ICRF System')
xlabel('x')
ylabel('y')
zlabel('z')
grid on
hold off