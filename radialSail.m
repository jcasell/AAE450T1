function [vF,fpaF,tof] = radialSail(r0,v0,rF,beta)
muSun = 132712440017.99; %km^3/s^2
modifiedMu = muSun * (1 - beta);

% vEsc = sqrt(2 * modifiedMu / r0);
% fpa0 = 0; %Assume initial departure from solar periapsis

% sma = 0.5 * (modifiedMu / ((modifiedMu / r0) - (v0^2 / 2))); %Calculate semimajor axis
sma = r0*((1 - beta)/(1 - (2*beta)));
% ecc = sqrt(((0.5 * r0 * v0^2)/modifiedMu - 1)^2 * cosd(fpa0)^2 + sind(fpa0)^2);
ecc = 1 - ((1 - 2*beta)/(1 - beta));

if beta > 0.5 %Orbit type is hyperbolic if velocity greater than escape
    orbitType = "Hyperbolic";
else
    orbitType = "Elliptic";
end

% initialTA = abs(acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1)));
% finalTA = acosd(1 / ecc * (sma*(1 - ecc^2)/rF - 1));

if orbitType == "Elliptic"
    % True Anomaly
    finalTA = acosd(1 / ecc * (sma*(1 - ecc^2)/rF - 1));
    % Eccentric Anomaly
    finalE = 2*atan2(tand(finalTA/2), sqrt((1 + ecc)/(1-ecc)));

    % TOF, Velocity, and Position 
    tof = sqrt(sma^3/modifiedMu) * (finalE - ecc*sin(finalE));
    vF = sqrt((2*modifiedMu/rF) - (modifiedMu/sma));
    fpaF = atan2d(ecc*sind(finalTA),1 + ecc*cosd(finalTA));
elseif orbitType == "Hyperbolic"
    % True Anomaly
    finalTA = acosd(1 / ecc * (abs(sma)*(ecc^2 - 1)/rF - 1));
    % Hyperbolic Anomaly
    finalH = 2*atanh(tand(finalTA/2) / sqrt((ecc+1)/(ecc-1)));
    
    % TOF, Velocity, and Position 
    tof = sqrt(abs(sma)^3 / modifiedMu) * (ecc*sinh(finalH) - finalH);
    vF = sqrt((2*modifiedMu/rF) + (modifiedMu/abs(sma)));
    fpaF = atan2d(ecc*sind(finalTA),1 + ecc*cosd(finalTA));
end

tof = tof / (3600 * 24 * 365.25); %Convert time of flight from seconds to Julian years