function [sma, ecc, ta0,taf] = getTA(r0,v0,rF,fpa0)

muSun = 132712440017.99; %km^3/s^2

%This function determines the true anomaly at the beginning and end of the
%spacecraft trajectory leg.

%Check if orbit type is elliptic or hyperbolic
vEsc = sqrt(2*muSun/r0); %Escape velocity from given r

if v0 > vEsc %Orbit type is hyperbolic if velocity greater than escape
    orbitType = "Hyperbolic";
else
    orbitType = "Elliptic";
end

sma = 0.5 * (muSun / ((muSun / r0) - (v0^2 / 2))); %Calculate semimajor axis
ecc = sqrt(((r0 * v0^2)/muSun - 1)^2 * cosd(fpa0)^2 + sind(fpa0)^2);

if orbitType == "Elliptic"
    ta0 = acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1));
    taf = acosd(1 / ecc * (sma*(1 - ecc^2)/rF - 1));
elseif orbitType == "Hyperbolic"
    ta0 = acosd(1 / ecc * (abs(sma)*(ecc^2 - 1)/r0 - 1));
    taf = acosd(1 / ecc * (abs(sma)*(ecc^2 - 1)/rF - 1));
end
