function totalDistance = time2dist(r0, v0, elapsedTime, fpa0)

muSun = 132712440017.99; %km^3/s^2
au2km = 149597870.691; %Converts AU to kilometers

sma = 0.5 * (muSun / ((muSun / r0) - (v0^2 / 2))); %Calculate semimajor axis
ecc = sqrt(((r0 * v0^2 / muSun) - 1)^2 * cosd(fpa0)^2 + sind(fpa0)^2);

checkFlag = 0;

initialTA = acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1));
initialH = 2*atanh(tand(initialTA/2) * sqrt((ecc - 1)/(ecc + 1)));

% t2p = (ecc*sinh(initialH) - initialH) / sqrt(muSun / abs(sma)^3);
guessR = 150 * au2km;

while checkFlag == 0 
    finalTA = acosd(1 / ecc * (sma*(1 - ecc^2)/guessR - 1));
    finalH = 2*atanh(tand(finalTA/2) * sqrt((ecc - 1)/(ecc + 1)));
    
    travelTime = (ecc*sinh(finalH) - finalH - ecc*sinh(initialH) + initialH) / sqrt(muSun / abs(sma)^3);
    travelTime = travelTime / (3600*24*365.25);
    %coastPhase = travelTime - t2p; coastPhase = coastPhase / (3600*24*365.25);
   
    %checkParam = 35 - (coastPhase + elapsedTime);
    checkParam = elapsedTime - travelTime;
    if abs(checkParam) <= 0.25 %Time of flight must be within a certain year range. Here, it is 0.5 years (6 months)
        checkFlag = 1;
    end

    if checkParam > 0
        guessR = guessR*1.005;
    else
        guessR = guessR*0.995;
    end
end

totalDistance = guessR;