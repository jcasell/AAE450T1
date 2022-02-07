function [tof, vF, reqFpa] = logarithmicSpiral(r0, rF,beta)
muSun = 132712440017.99; %Gravitational parameter of the sun [km^3/s^2];

alphaList = linspace(0,50,100);
checkList = 2 .* (1 - 2.*tand(alphaList).^2) ./ (cosd(alphaList) .* (2 - tand(alphaList).^2));
difList = abs(beta - checkList); idealAlpha = alphaList(difList == min(difList));

tof = abs(1/3 * (rF^1.5 - r0^1.5) * sqrt((1 - beta*cosd(idealAlpha)^3) / (beta^2 * muSun * cosd(idealAlpha)^4*sind(idealAlpha)^2)));
reqFpa = atan2d(2*beta*cosd(idealAlpha)^2*sind(idealAlpha),1 - beta*cosd(idealAlpha)^3);
if r0 > rF %Check if spiral is moving in or out; assign FPA accordingly
    reqFpa = -reqFpa;
end

vF = sqrt(muSun / rF) * sqrt(1 - beta*cosd(idealAlpha)^2 * (cosd(idealAlpha) - sind(idealAlpha)*tand(reqFpa)));