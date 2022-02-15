clear
clc
% function Data = ElectricProp(totalTime,m_pay)
totalTime = [7.57,1.57,3.142];
m_pay = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: ElectricProp
%Description:
%Inputs:
%Outputs:
%Author: Thomas Beimrohr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

km2au = 1/149597870.691; %Converts AU to kilometers
au2km = 149597870.691;

phase1R = 75*au2km;
phase2R = 90*au2km;
phase3R = 120*au2km;
%Convert Phase time to Seconds
t1 = totalTime(1)*365*24*3600; %s
t2 = totalTime(2)*365*24*3600; %s
t3 = totalTime(3)*365*24*3600; %s

g = 9.81;%m/s
eta = .5;
BHT_600_T = (39/1000); %N
BHT_600_P = 300; %W
BHT_600_Pjet = BHT_600_P*eta;
BHT_600_ISP = 1500; %s
BHT_600_M = 2.8; %kg
BHT_600_UE = BHT_600_Pjet*2/BHT_600_T; %m/s
BHT_600_mdot = BHT_600_T/BHT_600_UE; %kg/s

BHT_600_Mprop2 = BHT_600_mdot*t2; %kg
m_craft1a = m_pay + BHT_600_Mprop2 + BHT_600_M;
delta_V1a = BHT_600_ISP*g*log(m_craft1a/(m_pay+BHT_600_M)); %m/s
lambda2 = BHT_600_Mprop2/(BHT_600_Mprop2+BHT_600_M);

BHT_600_Mprop3 = BHT_600_mdot*t3; %kg
m_craft2a = m_pay + BHT_600_Mprop3 + BHT_600_M;
delta_V2a = BHT_600_ISP*g*log(m_craft2a/(m_pay+BHT_600_M)); %m/s
lambda3 = BHT_600_Mprop3/(BHT_600_Mprop3+BHT_600_M);

figure(1)
Name = ["Phase 1";"Phase 2"];
Time_of_Flight_years = [totalTime(2);totalTime(3)];
Propellant_Mass = [BHT_600_Mprop2;BHT_600_Mprop3];
Spacecraft_Mass = [m_craft1a;m_craft2a];
DeltaV_kms = [delta_V1a/1000;delta_V2a/1000];
Lambda = [lambda2;lambda3];
T = table(Name,Time_of_Flight_years,Propellant_Mass,Spacecraft_Mass,DeltaV_kms,Lambda);
TString = evalc('disp(T)');
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
FixedWidth = get(0,'FixedWidthFontName'); set(gcf,'Position',[100 100 600 100]) 
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);


