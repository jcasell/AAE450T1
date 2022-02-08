function [tof] = modTof(r0,v0, rF,beta)
muSun = 132712440017.99; %Gravitational parameter of the sun [km^3/s^2];
%This function determines the time of flight between two points given
%orbital information. Inputs are initial and final orbital radii (r0 and
%rF) as well as initial heliocentric orbital velocity (v0). The initial
%flight path angle from the departure point is also required. Also, the
%modified gravitational parameter due to a solar / electric sail is
%required

mu = muSun * (1 - beta); %Determine modified gravitational parameter based on sail lightness parameter

%Check if orbit type is elliptic or hyperbolic
vEsc = sqrt(2*mu/r0); %Escape velocity from given r

if v0 > vEsc %Orbit type is hyperbolic if velocity greater than escape
    orbitType = "Hyperbolic";
else
    orbitType = "Elliptic";
end

sma = 0.5 * (mu / ((mu / r0) - (v0^2 / 2))); %Calculate semimajor axis
ecc = 1 - (r0/sma);

initialTA = abs(acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1)));
finalTA = abs(acosd(1 / ecc * (sma*(1 - ecc^2)/rF - 1)));

if orbitType == "Elliptic"
    initialE = 2*atan2(tand(initialTA/2), sqrt((1 + ecc)/(1-ecc)));
    finalE = 2*atan2(tand(finalTA/2), sqrt((1 + ecc)/(1-ecc)));

    tof = sqrt(sma^3/mu) * (finalE - ecc*sin(finalE) - (initialE - ecc*sin(initialE)));
elseif orbitType == "Hyperbolic"
    initialH = 2*atanh(tand(initialTA/2) / sqrt((ecc+1)/(ecc-1)));
    finalH = 2*atanh(tand(finalTA/2) / sqrt((ecc+1)/(ecc-1)));
    
    tof = sqrt(abs(sma)^3 / mu) * (ecc*sinh(finalH) - finalH - (ecc*sinh(initialH) - initialH));
end