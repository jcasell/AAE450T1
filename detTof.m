function [tof, initialTA, finalTA, sma, ecc] = detTof(r0,v0,rF,fpa0)

muSun = 132712440017.99; %km^3/s^2, gravitational parameter of the sun

%This function determines the time of flight between two points given
%orbital inf`ormation. Output time of flight is in Julian Years (365.25
%Julian days per Julian year)

%Check if orbit type is elliptic or hyperbolic
vEsc = sqrt(2*muSun/r0); %Escape velocity from given r around the sun

if v0 > vEsc %Orbit type is hyperbolic if velocity greater than escape velocity
    orbitType = "Hyperbolic";
else
    orbitType = "Elliptic";
end

sma = 0.5 * (muSun / ((muSun / r0) - (v0^2 / 2))); %Calculate semimajor axis of heliocentric orbit
ecc = sqrt(((r0 * v0^2)/muSun - 1)^2 * cosd(fpa0)^2 + sind(fpa0)^2); %Caclulate eccentricity of heliocentric orbit

if orbitType == "Elliptic"
    initialTA = acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1)); %Determine the initial true anomaly around the sun
    initialE = 2*atan2(tand(initialTA/2), sqrt((1 + ecc)/(1-ecc))); %Convert initial TA to eccentric anomaly

    finalTA = acosd(1 / ecc * (sma*(1 - ecc^2)/rF - 1)); %Repeat above process for final true anomaly
    finalE = 2*atan2(tand(finalTA/2), sqrt((1 + ecc)/(1-ecc)));

    tof = sqrt(sma^3/muSun) * (finalE - ecc*sin(finalE) - (initialE - ecc*sin(initialE))); %Use Kepler's equation to determine time of flight between two points on orbit
elseif orbitType == "Hyperbolic"
    initialTA = acosd(1 / ecc * (abs(sma)*(ecc^2 - 1)/r0 - 1)); %Determine initial true anomaly
    initialH = 2*atanh(tand(initialTA/2) / sqrt((ecc+1)/(ecc-1))); %Convert to equivalent hyperbolic anomaly

    finalTA = acosd(1 / ecc * (abs(sma)*(ecc^2 - 1)/rF - 1)); %Repeat above process for final true anomaly
    finalH = 2*atanh(tand(finalTA/2) / sqrt((ecc+1)/(ecc-1)));
    
    tof = sqrt(abs(sma)^3 / muSun) * (ecc*sinh(finalH) - finalH - (ecc*sinh(initialH) - initialH)); %Determine time of flight using Kepler's equation
end
tof = tof / (3600 * 24 * 365.25); %Convert time of flight from seconds to Julian years
