function [vArr, fpaArr] = getFPA(r0,v0,rF,fpaDep)
%Takes as input initial and final orbital radius and initial velocity
%Output is arrival velocity at final radius and corresponding flight path
%angle. Velocity in km/s and FPA in degrees.

muSun = 132712440017.99; %km^3/s^2, gravitational parameter of the sun

sma = 0.5 * (muSun / ((muSun / r0) - (v0^2 / 2))); %Calculate semimajor axis of heliocentric orbit
ecc = sqrt(((r0 * v0^2 / muSun) - 1)^2 * cosd(fpaDep)^2 + sind(fpaDep)^2); %Calculate eccentricity of heliocentric orbit

vArr = sqrt(2*muSun*(1/rF - 1/(2*sma))); %Velocity at final orbital radius

angMom = sqrt(muSun * sma * (1 - ecc^2)); %Determine angular momentum of the orbit
fpaArr = abs(acosd(angMom/(rF*vArr))); %Flight path angle at final orbital radius; uses h = rv*cos(gamma) where gamma is the flight path angle