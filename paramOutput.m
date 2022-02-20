function [paramList] = paramOutput(trajectoryOption, v_inf)

paramList = zeros(3,4);

aEarth = 149597898; aJup = 778279959;
aSat = 1427387908; aMars = 227956000; %Semimajor axes of Earth, Jupiter, Mars, and Saturn

if trajectoryOption == "JupSat"
    rList = [aEarth,aJup,aSat];
    planetList = ["Jupiter","Saturn"];
elseif trajectoryOption == "MarsJup"
    rList = [aEarth,aMars,aJup];
    planetList = ["Mars","Jupiter"];
end

muSun = 132712440017.99; % grav parameter of sun [km^3/s^2]


vEarth = sqrt(2*muSun/aEarth); %velocity of Earth relative to Sun [km/s]
v0 = v_inf + vEarth; %initial velocity of s/c relative to sun [km/s]

currentV = v0; currentFPA = 0;

for i = 1:2
    [sma, ecc, ta0,taf] = getTA(rList(i),currentV,rList(i+1),currentFPA);
    [vArrival, fpaArr] = getFPA(rList(i),currentV,rList(i+1),currentFPA);
    [currentV,currentFPA,eqDV] = gravityAssist(planetList{i},vArrival,fpaArr);

    paramList(i,:) = [sma,ecc,ta0,taf];
end

disp(paramList);