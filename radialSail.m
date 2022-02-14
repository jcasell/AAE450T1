function tof = radialSail(r0,v0,rF,beta)
muSun = 132712440017.99; %km^3/s^2
modifiedMu = muSun * (1 - beta);

vEsc = sqrt(2 * modifiedMu / r0);
fpa0 = 0; %Assume initial departure from solar periapsis

sma = 0.5 * (modifiedMu / ((modifiedMu / r0) - (v0^2 / 2))); %Calculate semimajor axis
ecc = sqrt(((0.5 * r0 * v0^2)/modifiedMu - 1)^2 * cosd(fpa0)^2 + sind(fpa0)^2);

if v0 > vEsc %Orbit type is hyperbolic if velocity greater than escape
    orbitType = "Hyperbolic";
else
    orbitType = "Elliptic";
end

initialTA = abs(acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1)));
finalTA = abs(acosd(1 / ecc * (sma*(1 - ecc^2)/rF - 1)));

if orbitType == "Elliptic"
    initialE = 2*atan2(tand(initialTA/2), sqrt((1 + ecc)/(1-ecc)));
    finalE = 2*atan2(tand(finalTA/2), sqrt((1 + ecc)/(1-ecc)));
    if finalE < 0
        finalE = finalE + 2*pi;
    end

    tof = sqrt(sma^3/modifiedMu) * (finalE - ecc*sin(finalE) - (initialE - ecc*sin(initialE)));
elseif orbitType == "Hyperbolic"
    initialH = 2*atanh(tand(initialTA/2) / sqrt((ecc+1)/(ecc-1)));
    finalH = 2*atanh(tand(finalTA/2) / sqrt((ecc+1)/(ecc-1)));
    
    tof = sqrt(abs(sma)^3 / modifiedMu) * (ecc*sinh(finalH) - finalH - (ecc*sinh(initialH) - initialH));
end

tof = tof / (3600 * 24 * 365.25); %Convert time of flight from seconds to Julian years