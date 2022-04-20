clc; clear; close all;

muJup = 126712767.8578;
muSun = 132712440017.99; %km^3/s^2, JPL

maxRad = 400;
jupDist = 1:1:maxRad;
jupRad = jupDist * 71492;
solRad = jupRad + 778279959;

jupForce = muJup ./ jupRad.^2;
sunForce = muSun ./ solRad.^2;


semilogy(jupDist, jupForce); hold on; semilogy(jupDist, sunForce);
xlabel('Jupiter Distance [Jupiter Radii]'); ylabel('Gravitational Acceleration [km/s]')
legend('Jupiter Graviational Acceleration','Solar Gravitational Acceleration');
title('Comparison of Gravitational Accelerations Around Jupiter');
set(gca,'fontsize',14);
xline(100);