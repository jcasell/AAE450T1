function [vf,rf,fpaf] = electricTrajectory(v0,r0,fpa0,tof,dV)
% This function will take initial velocity, distance, and flight path angle
% of heliocentric orbit, as well as time of electric engine burn and
% delta V to get the final distance. velocity and fpa
%% Calculations
muSun = 132712440017.99; %km^3/s^2, solar gravitational parameter

sma = 0.5 * (muSun / ((muSun / r0) - (v0^2 / 2))); %Calculate semimajor axis
ecc = sqrt(((r0 * v0^2 / muSun) - 1)^2 * cosd(fpa0)^2 + sind(fpa0)^2); %Calculates eccentricity of heliocentric orbit

initialTA = acosd(1 / ecc * (sma*(1 - ecc^2)/r0 - 1)); %From orbital parameters, determine the initial true anomaly
initialH = 2*atanh(tand(initialTA/2) * sqrt((ecc - 1)/(ecc + 1))); %Convert initial true anomaly to equivalent hyperbolic anomaly

checkFlag = 0; %Used to break out of loop
guessR = r0 + 25000; %Initial guess for how far spacecraft has traveled at end of lifespan

while checkFlag == 0 %Iterate until internal condition is met
    finalTA = acosd(1 / ecc * (sma*(1 - ecc^2)/guessR - 1)); %Calculate final true anomaly based on guess radial distance R
    finalH = 2*atanh(tand(finalTA/2) * sqrt((ecc - 1)/(ecc + 1))); %Convert final true anomaly to equivalent hyperbolic anomaly
    
    travelTime = (ecc*sinh(finalH) - finalH - ecc*sinh(initialH) + initialH) / sqrt(muSun / abs(sma)^3); %Determine time of flight between two hyperbolic anomalies on the orbit
   
    checkParam = tof - travelTime; %Calculate the difference between the flight time and elapsedTime 
    if abs(checkParam) <= 10 %Time of flight must be within 1 second
        checkFlag = 1; %Break out of the loop if radial distance guess gives TOF within 10 seconds of input
    end

    if checkParam > 0 %If the time of flight is not within bounds, scale the guess accordingly
        guessR = guessR+5; %Make the R bigger if travel time is not big enough
    else
        guessR = guessR-5; %Make the R smaller if travel time is too big
    end
end
rf = guessR;
vf = sqrt(2*muSun*(1/rf - 1/(2*sma))) + dV; %velocity at end of iteration plus delta V from engine
angMom = sqrt(muSun * sma * (1 - ecc^2)); %Determine angular momentum of the orbit
fpaf = abs(acosd(angMom/(rf*vf))); %Flight path angle at final distance
end