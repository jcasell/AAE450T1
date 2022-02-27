function paramList = paramOutput(inputVals)

muSun = 132712440017.99; % grav parameter of sun [km^3/s^2]
paramList = zeros(length(inputVals),4);

for i = 1:length(inputVals)
    rad = inputVals(i,1); vel = inputVals(i,2); fpa = inputVals(i,3);
    
    sma = 0.5 * (muSun / ((muSun / rad) - (vel^2 / 2))); %Calculate semimajor axis of heliocentric orbit

    ecc = sqrt(((rad * vel^2 / muSun) - 1)^2 * cosd(fpa)^2 + sind(fpa)^2); %Calculate eccentricity of heliocentric orbit

    paramList(i,:) = [sma, ecc, inputVals(i,4),inputVals(i,5)];
end