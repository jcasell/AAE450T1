function [vf,rf,fpaf,stageTime,mp_res] = Burn_eProp(mcraft,Vo,Ro,Fpao,Rlimit,mp)
au2km = 149597870.691;
g = 9.81; %m/s2
i = 1;
t(1) = 0;
%% Hardcoded values DELETE WHEN IN GITHUB
% mcraft = 500;
% Vo = 40; %m/s
% Ro = 3; %au
% Fpao = 80;
v0(1) = Vo; 
r0(1) = Ro;
fpa0(1) = Fpao;
% Rlimit = 40*au2km; %input in au
%%
% ​
if  exist('mp',"var")
    BHT_200_Mprop2(1) = mp; %kg
else
    mass_available = mcraft*.13; %kg
    BHT_200_Mprop2(1) = mass_available; %kg
end
%​
eta = .92; %estimated off of BHT 100
BHT_200_T = (17/1000); %N
BHT_200_P = 200; %W
BHT_200_Pjet = BHT_200_P*eta;
BHT_200_ISP = 1390; %s
BHT_200_M = 1; %kg
BHT_200_UE = BHT_200_Pjet*2/BHT_200_T; %m/s
BHT_200_mdot = BHT_200_T/BHT_200_UE; %kg/s
%​
m_craft_burn(1) = mcraft + BHT_200_Mprop2(1) + BHT_200_M; %kg
delta_V = BHT_200_ISP*g*log(m_craft_burn(1)/(mcraft+BHT_200_M)); %m/s
delta_Vi(1) = 0; %m/s
BurnTime_total = (BHT_200_Mprop2(1)/BHT_200_mdot)/(365*24*3600); %s
flag = 1;
%​
days = 1;
dt = days*24*60*60; %days in seconds
%​
while (BHT_200_Mprop2(i) > 0) & flag
    t(i+1) = t(i) + dt;
    BHT_200_Mprop2(i+1) = BHT_200_Mprop2(i) - BHT_200_mdot*dt;
    m_craft_burn(i+1) = mcraft + BHT_200_Mprop2(i+1) + BHT_200_M;
    delta_Vi(i+1) = BHT_200_ISP*g*log(m_craft_burn(i)/(m_craft_burn(i+1))); %m/s
    [v0(i+1),r0(i+1),fpa0(i+1)] = electricTrajectory(v0(i),r0(i),fpa0(i),dt,(delta_Vi(i+1))/1000);
    if exist('Rlimit',"var") & (r0(i+1) >= Rlimit)
        flag = 0;
        mp_res = BHT_200_Mprop2(i+1);
    end
    i = i + 1;
end
%​
rf = r0(end);
vf = v0(end);
fpaf = fpa0(end);
if ~exist('Rlimit',"var")
        mp_res = 0;
end
stageTime = t(end)/(3600 * 24 * 365.25);
