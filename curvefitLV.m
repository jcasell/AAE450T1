% Code to curvefit Launch vehicle C3 values vs mass of payload
clc;
clear all;

C3 = [0,10,20,30,40,50,60,70,80,83,90,100,110,120];
Mass = [44.3, 37.6, 31.6, 26.4, 21.8, 17.9, 14.4, 11.4, 8.8, 8.0, 6.4, 4.4, 2.6, 0.9].*1000; %kg


coefficients = polyfit(Mass, C3, 3);

xFit = linspace(min(Mass), max(Mass), 1000);
yFit = polyval(coefficients , xFit);

plot(Mass, C3, 'b.', 'MarkerSize', 15);
hold on; % Set hold on so the next plot does not blow away the one we just drew.
plot(xFit, yFit, 'r-', 'LineWidth', 2); % Plot fitted line.
grid on;