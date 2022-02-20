function [paramList] = paramOutput(trajectoryOption, v_inf,deltaV)

paramList = zeros(3,4);

muSun = 132712440017.99; % grav parameter of sun [km^3/s^2]

aEarth = 149597898; aJup = 778279959; aSat = 1427387908; %Semimajor axes of Earth, Jupiter, and Saturn

vEarth = sqrt(2*muSun/aEarth); %velocity of Earth relative to Sun [km/s]
v0 = v_inf + vEarth; %initial velocity of s/c relative to sun [km/s]

vEsc = sqrt(2*muSun/aEarth);


if v0 >= vEsc
    orbitType = "Hyperbolic";
else
    orbitType = "Elliptic";
end

for i = 1:3
    [sma, ecc, ta0,taf] = getTA(aEarth,v0,aJup,0);
    paramList(i,:) = [sma,ecc,ta0,taf];
end

disp(paramList);
