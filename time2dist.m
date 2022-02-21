function totalDistance = time2dist(r0, v0, elapsedTime, fpa0)
%This function converts a travel time toa heliocentric radial distance
%based on initial conditions and a travel time. Output is
%totalDistance which is the radial distance between the spacecraft and the
%sun measured in kilometers. Function assumes that the orbit is hyperbolic
%as this code is used to prpagate a trajectory during the spacecraft's
%final coast phase to its expected end of life.

muSun = 132712440017.99; %km^3/s^2, solar gravitational parameter
au2km = 149597870.691; %Converts AU to kilometers

sma = 0.5 * (muSun / ((muSun / r0) - (v0^2 / 2))); %Calculate semimajor axis
ecc = sqrt(((r0 * v0^2 / muSun) - 1)^2 * cosd(fpa0)^2 + sind(fpa0)^2); %Caclulates eccentricity of heliocentric orbit

initialTA = acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1)); %From orbital parameters, determine the initial true anomaly
initialH = 2*atanh(tand(initialTA/2) * sqrt((ecc - 1)/(ecc + 1))); %Convert initial true anomaly to equivalent hyperbolic anomaly

checkFlag = 0; %Used to break out of loop
guessR = 150 * au2km; %Initial guess for how far spacecraft has traveled at end of lifespan

while checkFlag == 0 %Iterate until internal condition is met
    finalTA = acosd(1 / ecc * (sma*(1 - ecc^2)/guessR - 1)); %Calculate final true anomaly based on guess radial distance R
    finalH = 2*atanh(tand(finalTA/2) * sqrt((ecc - 1)/(ecc + 1))); %Convert final true anomaly to equivalent hyperbolic anomaly
    
    travelTime = (ecc*sinh(finalH) - finalH - ecc*sinh(initialH) + initialH) / sqrt(muSun / abs(sma)^3); %Determine time of flight between two hyperbolic anomalies on the orbit
    travelTime = travelTime / (3600*24*365.25); %Convert the travel time to Julian years
   
    checkParam = elapsedTime - travelTime; %Calculate the difference between the flight time and elapsedTime, the remaining spacecraft lifetime 
    if abs(checkParam) <= 0.25 %Time of flight must be within a certain year range. Here, it is 0.25 years (3 months)
        checkFlag = 1; %Break out of the loop if radial distance guess gives time of flight within three months of remaining spacecraft lifetime
    end

    if checkParam > 0 %If the time of flight is not within bounds, scale the guess accordingly
        guessR = guessR*1.005; %Make the R bigger if travel time is not big enough
    else
        guessR = guessR*0.995; %Make the R smaller if travel time is too big
    end
end

totalDistance = guessR; %Assign guess radial distance to output variable