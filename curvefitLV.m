% Code to curvefit Launch vehicle C3 values vs mass of payload
clc;
clear all;

C3 = [0,5,10,15,20,25,30];
Mass_V6S = [7180, 6360, 4930, 3605, 2365, 1205, 120];

C3_sls = [-3 0   5 10 20 30 40 50 60 70 80 90 100 160];
Payload_mass_sls = [28 27 24 22 18 15 13 11 9 7.5 6.5 5.25 4 1].*1000; %kg


coefficients = polyfit(Payload_mass_sls, C3_sls, 3);

xFit = linspace(min(Payload_mass_sls), max(Payload_mass_sls), 1000);
yFit = polyval(coefficients , xFit);

plot(Payload_mass_sls, C3_sls, 'b.', 'MarkerSize', 15);
hold on; % Set hold on so the next plot does not blow away the one we just drew.
plot(xFit, yFit, 'r-', 'LineWidth', 2); % Plot fitted line.
grid on;