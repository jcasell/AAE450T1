clear
clc
% function Data = ElectricProp(totalTime,m_pay)
totalTime = [7.57,1.57,3.142];
mass_available = 100; %kg
m_pay = 500;
deltaV_desired = [0,4,5]*1000; %km/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: ElectricProp
%Description:
%Inputs: spacecraft mass, time running
%Outputs: delta V, mass of propellant
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
i = 0;
g = 9.81;%m/s
choice = input('Defined by Time of Flight (1) or by Mass (2) or Delta V (3)\n');
if choice == 1
    %% Hall Thruster
    %% BHT 600
    eta = .85; %estimated off of BHT 100
    BHT_600_T = (39/1000); %N
    BHT_600_P = 300; %W
    BHT_600_Pjet = BHT_600_P*eta;
    BHT_600_ISP = 1500; %s
    BHT_600_M = 2.8; %kg
    BHT_600_UE = BHT_600_Pjet*2/BHT_600_T; %m/s
    BHT_600_mdot = BHT_600_T/BHT_600_UE; %kg/s

    BHT_600_Mprop2 = BHT_600_mdot*t2; %kg
    BHT_600_Mprop3 = BHT_600_mdot*t3; %kg

    m_craft1a = m_pay + BHT_600_Mprop2 + BHT_600_M +BHT_600_Mprop3;
    delta_V1a = BHT_600_ISP*g*log(m_craft1a/(m_pay+BHT_600_M + BHT_600_Mprop3)); %m/s
    m_craft2a = m_pay + BHT_600_Mprop3 + BHT_600_M;
    delta_V2a = BHT_600_ISP*g*log(m_craft2a/(m_pay+BHT_600_M)); %m/s
    BurnTime = [totalTime(2);totalTime(3);totalTime(2)+totalTime(3)];
    %% BHT 100
    eta = .92; % estimated average from data sheet https://static1.squarespace.com/static/60df2bfb6db9752ed1d79d44/t/6154811d7ac4036af765f736/1632928031263/BHT_100_v1.0.pdf
    BHT_100_T = (7/1000); %N
    BHT_100_P = 75; %W
    BHT_100_Pjet = BHT_100_P*eta;
    BHT_100_ISP = 1000; %s
    BHT_100_M = 1.16; %kg
    BHT_100_UE = BHT_100_Pjet*2/BHT_100_T; %m/s
    BHT_100_mdot = BHT_100_T/BHT_100_UE; %kg/s

    BHT_100_Mprop2 = BHT_100_mdot*t2; %kg
    BHT_100_Mprop3 = BHT_100_mdot*t3; %kg

    m_craft1b = m_pay + BHT_100_Mprop2 + BHT_100_M +BHT_100_Mprop3;
    delta_V1b = BHT_100_ISP*g*log(m_craft1b/(m_pay+BHT_100_M + BHT_100_Mprop3)); %m/s
    m_craft2b = m_pay + BHT_100_Mprop3 + BHT_100_M;
    delta_V2b = BHT_100_ISP*g*log(m_craft2b/(m_pay+BHT_100_M)); %m/s
    BurnTime = [totalTime(2);totalTime(3);totalTime(2)+totalTime(3)];
    %% Ion Thruster
    eta2 = .9;
    array_num = 1;
    BIT_3T = (1.1/1000)*array_num; %N
    BIT_3P = 56*array_num; %W
    BIT_3Pjet = BIT_3P*eta2;
    BIT_3_ISP = 2150; %s
    BIT_3T_M = 1.4*array_num; %kg
    BIT_3_UE = BIT_3Pjet*2/BIT_3T; %m/s
    BIT_3_mdot = BIT_3T/BIT_3_UE; %kg/s

    BIT_3_Mprop2 = BIT_3_mdot*t2; %kg
    BIT_3_Mprop3 = BIT_3_mdot*t3; %kg

    m_craft1c = m_pay + BIT_3_Mprop2 + BIT_3T_M + BIT_3_Mprop3;
    delta_V1c = BIT_3_ISP*g*log(m_craft1c/(m_pay+BIT_3T_M + BIT_3_Mprop3)); %m/s
    m_craft2c = m_pay + BIT_3_Mprop3 + BIT_3T_M;
    delta_V2c = BIT_3_ISP*g*log(m_craft2c/(m_pay+BIT_3T_M)); %m/s
    BurnTime = [totalTime(2);totalTime(3);totalTime(2)+totalTime(3)];
    BurnTime = [BurnTime BurnTime BurnTime BurnTime];
elseif choice == 2
    %% Hall Thruster
    %% BHT 600
    eta = .85; %estimated off of BHT 100
    BHT_600_T = (39/1000); %N
    BHT_600_P = 300; %W
    BHT_600_Pjet = BHT_600_P*eta;
    BHT_600_ISP = 1500; %s
    BHT_600_M = 2.8; %kg
    BHT_600_UE = BHT_600_Pjet*2/BHT_600_T; %m/s
    BHT_600_mdot = BHT_600_T/BHT_600_UE; %kg/s

    BHT_600_Mprop2 = mass_available; %kg
    BHT_600_Mprop3 = 0;

    m_craft1a = m_pay + BHT_600_Mprop2 + BHT_600_M +BHT_600_Mprop3;
    delta_V1a = BHT_600_ISP*g*log(m_craft1a/(m_pay+BHT_600_M + BHT_600_Mprop3)); %m/s
    m_craft2a = m_pay + BHT_600_Mprop3 + BHT_600_M;
    delta_V2a = BHT_600_ISP*g*log(m_craft2a/(m_pay+BHT_600_M)); %m/s
    BurnTime(1,2) = (BHT_600_Mprop2/BHT_600_mdot)/(365*24*3600);
    BurnTime(2,2) = (BHT_600_Mprop3/BHT_600_mdot)/(365*24*3600);
    BurnTime(3,2) = BurnTime(1,2) + BurnTime(2,2);
    %% BHT 100
    eta = .92; % estimated average from data sheet https://static1.squarespace.com/static/60df2bfb6db9752ed1d79d44/t/6154811d7ac4036af765f736/1632928031263/BHT_100_v1.0.pdf
    BHT_100_T = (7/1000); %N
    BHT_100_P = 75; %W
    BHT_100_Pjet = BHT_600_P*eta;
    BHT_100_ISP = 1000; %s
    BHT_100_M = 1.16; %kg
    BHT_100_UE = BHT_100_Pjet*2/BHT_100_T; %m/s
    BHT_100_mdot = BHT_100_T/BHT_100_UE; %kg/s

    BHT_100_Mprop2 = mass_available; %kg
    BHT_100_Mprop3 = 0; %kg

    m_craft1b = m_pay + BHT_100_Mprop2 + BHT_100_M +BHT_100_Mprop3;
    delta_V1b = BHT_100_ISP*g*log(m_craft1b/(m_pay+BHT_100_M + BHT_100_Mprop3)); %m/s
    m_craft2b = m_pay + BHT_100_Mprop3 + BHT_100_M;
    delta_V2b = BHT_100_ISP*g*log(m_craft2b/(m_pay+BHT_100_M)); %m/s
    BurnTime(1,3) = (BHT_100_Mprop2/BHT_100_mdot)/(365*24*3600);
    BurnTime(2,3) = (BHT_100_Mprop3/BHT_100_mdot)/(365*24*3600);
    BurnTime(3,3) = BurnTime(1,3) + BurnTime(2,3);
    %% Ion Thruster
    eta2 = .9;
    array_num = 1;
    BIT_3T = (1.1/1000)*array_num; %N
    BIT_3P = 56*array_num; %W
    BIT_3Pjet = BIT_3P*eta2;
    BIT_3_ISP = 2150; %s
    BIT_3T_M = 1.4*array_num; %kg
    BIT_3_UE = BIT_3Pjet*2/BIT_3T; %m/s
    BIT_3_mdot = BIT_3T/BIT_3_UE; %kg/s

    BIT_3_Mprop2 = mass_available; %kg
    BIT_3_Mprop3 = 0; %kg

    m_craft1c = m_pay + BIT_3_Mprop2 + BIT_3T_M + BIT_3_Mprop3;
    delta_V1c = BIT_3_ISP*g*log(m_craft1c/(m_pay+BIT_3T_M + BIT_3_Mprop3)); %m/s
    m_craft2c = m_pay + BIT_3_Mprop3 + BIT_3T_M;
    delta_V2c = BIT_3_ISP*g*log(m_craft2c/(m_pay+BIT_3T_M)); %m/s
    BurnTime(1,4) = (BIT_3_Mprop2/BIT_3_mdot)/(365*24*3600);
    BurnTime(2,4) = (BIT_3_Mprop3/BIT_3_mdot)/(365*24*3600);
    BurnTime(3,4) = BurnTime(1,4) + BurnTime(2,4);
    i = 1;
elseif choice == 3
    %% Hall Thruster
    %% BHT 600
    eta = .85; %estimated off of BHT 100
    BHT_600_T = (39/1000); %N
    BHT_600_P = 300; %W
    BHT_600_Pjet = BHT_600_P*eta;
    BHT_600_ISP = 1500; %s
    BHT_600_M = 2.8; %kg
    BHT_600_UE = BHT_600_Pjet*2/BHT_600_T; %m/s
    BHT_600_mdot = BHT_600_T/BHT_600_UE; %kg/s

    BHT_600_Mprop3 = (BHT_600_M+m_pay)*exp(deltaV_desired(3)/(g*BHT_600_ISP)) - m_pay - BHT_600_M; %kg
    BHT_600_Mprop2 = (BHT_600_M+m_pay+BHT_600_Mprop3)*exp(deltaV_desired(2)/(g*BHT_600_ISP)) - m_pay - BHT_600_M - BHT_600_Mprop3; %kg

    m_craft1a = m_pay + BHT_600_Mprop2 + BHT_600_M +BHT_600_Mprop3;
    delta_V1a = BHT_600_ISP*g*log(m_craft1a/(m_pay+BHT_600_M + BHT_600_Mprop3)); %m/s
    m_craft2a = m_pay + BHT_600_Mprop3 + BHT_600_M;
    delta_V2a = BHT_600_ISP*g*log(m_craft2a/(m_pay+BHT_600_M)); %m/s
    BurnTime(1,2) = (BHT_600_Mprop2/BHT_600_mdot)/(365*24*3600);
    BurnTime(2,2) = (BHT_600_Mprop3/BHT_600_mdot)/(365*24*3600);
    BurnTime(3,2) = BurnTime(1,2) + BurnTime(2,2);
    %% BHT 100
    eta = .92; % estimated average from data sheet https://static1.squarespace.com/static/60df2bfb6db9752ed1d79d44/t/6154811d7ac4036af765f736/1632928031263/BHT_100_v1.0.pdf
    BHT_100_T = (7/1000); %N
    BHT_100_P = 75; %W
    BHT_100_Pjet = BHT_600_P*eta;
    BHT_100_ISP = 1000; %s
    BHT_100_M = 1.16; %kg
    BHT_100_UE = BHT_100_Pjet*2/BHT_100_T; %m/s
    BHT_100_mdot = BHT_100_T/BHT_100_UE; %kg/s

    BHT_100_Mprop3 = (BHT_100_M+m_pay)*exp(deltaV_desired(3)/(g*BHT_100_ISP)) - m_pay - BHT_100_M; %kg
    BHT_100_Mprop2 = (BHT_100_Mprop3+BHT_100_M+m_pay)*exp(deltaV_desired(2)/(g*BHT_100_ISP)) - m_pay - BHT_100_M -BHT_100_Mprop3; %kg

    m_craft1b = m_pay + BHT_100_Mprop2 + BHT_100_M +BHT_100_Mprop3;
    delta_V1b = BHT_100_ISP*g*log(m_craft1b/(m_pay+BHT_100_M + BHT_100_Mprop3)); %m/s
    m_craft2b = m_pay + BHT_100_Mprop3 + BHT_100_M;
    delta_V2b = BHT_100_ISP*g*log(m_craft2b/(m_pay+BHT_100_M)); %m/s
    BurnTime(1,3) = (BHT_100_Mprop2/BHT_100_mdot)/(365*24*3600);
    BurnTime(2,3) = (BHT_100_Mprop3/BHT_100_mdot)/(365*24*3600);
    BurnTime(3,3) = BurnTime(1,3) + BurnTime(2,3);
    %% Ion Thruster
    eta2 = .9;
    array_num = 1;
    BIT_3T = (1.1/1000)*array_num; %N
    BIT_3P = 56*array_num; %W
    BIT_3Pjet = BIT_3P*eta2;
    BIT_3_ISP = 2150; %s
    BIT_3T_M = 1.4*array_num; %kg
    BIT_3_UE = BIT_3Pjet*2/BIT_3T; %m/s
    BIT_3_mdot = BIT_3T/BIT_3_UE; %kg/s

    BIT_3_Mprop3 = (BIT_3T_M+m_pay)*exp(deltaV_desired(3)/(g*BIT_3_ISP)) - m_pay - BIT_3T_M; %kg
    BIT_3_Mprop2 = (BIT_3_Mprop3+BIT_3T_M+m_pay)*exp(deltaV_desired(2)/(g*BIT_3_ISP)) - m_pay - BIT_3T_M - BIT_3_Mprop3; %kg
    

    m_craft1c = m_pay + BIT_3_Mprop2 + BIT_3T_M + BIT_3_Mprop3;
    delta_V1c = BIT_3_ISP*g*log(m_craft1c/(m_pay+BIT_3T_M + BIT_3_Mprop3)); %m/s
    m_craft2c = m_pay + BIT_3_Mprop3 + BIT_3T_M;
    delta_V2c = BIT_3_ISP*g*log(m_craft2c/(m_pay+BIT_3T_M)); %m/s
    BurnTime(1,4) = (BIT_3_Mprop2/BIT_3_mdot)/(365*24*3600);
    BurnTime(2,4) = (BIT_3_Mprop3/BIT_3_mdot)/(365*24*3600);
    BurnTime(3,4) = BurnTime(1,4) + BurnTime(2,4);
    i = 1;
end
%% Plots
figure(1)
BurnTime1 = BurnTime(:,i+1);
Propellant_Mass = [BHT_600_Mprop2;BHT_600_Mprop3;BHT_600_Mprop2+BHT_600_Mprop3];
Spacecraft_Mass = [m_craft1a;m_craft2a;m_craft1a];
DeltaV_kms = [delta_V1a/1000;delta_V2a/1000;delta_V1a/1000 + delta_V2a/1000];
Power = [BHT_600_P;BHT_600_P;BHT_600_P];
T = array2table([BurnTime1,Propellant_Mass,Spacecraft_Mass,DeltaV_kms,Power],'VariableNames',{'Burn Time [years]' 'Propellant Mass [kg]' 'Spacecraft Mass [kg]' 'Delta V Added [km/s]' 'Power Required [W]'},'RowNames',{'Burn 1' 'Burn 2' 'Total'});
T = table(T,'VariableNames',{'BHT 600 Hall Thruster'});
TString = evalc('disp(T)');
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
FixedWidth = get(0,'FixedWidthFontName'); set(gcf,'Position',[100 100 850 100])
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);

figure(2)
BurnTime2 = BurnTime(:,i+2);
Propellant_Mass = [BHT_100_Mprop2;BHT_100_Mprop3;BHT_100_Mprop2 + BHT_100_Mprop3];
Spacecraft_Mass = [m_craft1b;m_craft2b;m_craft1b];
DeltaV_kms = [delta_V1b/1000;delta_V2b/1000;delta_V1b/1000 + delta_V2b/1000];
Power = [BHT_100_P;BHT_100_P;BHT_100_P];
T = array2table([BurnTime2,Propellant_Mass,Spacecraft_Mass,DeltaV_kms,Power],'VariableNames',{'Burn Time [years]' 'Propellant Mass [kg]' 'Spacecraft Mass [kg]' 'Delta V Added [km/s]' 'Power Required [W]'},'RowNames',{'Burn 1' 'Burn 2' 'Total'});
T = table(T,'VariableNames',{'BHT 100 Hall Thruster'});
TString = evalc('disp(T)');
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
FixedWidth = get(0,'FixedWidthFontName'); set(gcf,'Position',[100 275 850 100])
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);

figure(3)
BurnTime3 = BurnTime(:,i+3);
Propellant_Mass = [BIT_3_Mprop2;BIT_3_Mprop3;BIT_3_Mprop2 + BIT_3_Mprop3];
Spacecraft_Mass = [m_craft1c;m_craft2c;m_craft1c];
DeltaV_kms = [delta_V1c/1000;delta_V2c/1000; delta_V1c/1000 + delta_V2c/1000];
Power = [BIT_3P;BIT_3P;BIT_3P];
T = array2table([BurnTime3,Propellant_Mass,Spacecraft_Mass,DeltaV_kms,Power],'VariableNames',{'Burn Time [years]' 'Propellant Mass [kg]' 'Spacecraft Mass [kg]' 'Delta V Added [km/s]' 'Power Required [W]'},'RowNames',{'Burn 1' 'Burn 2' 'Total'});
T = table(T,'VariableNames',{'BIT 3 Ion Thruster'});
TString = evalc('disp(T)');
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
FixedWidth = get(0,'FixedWidthFontName'); set(gcf,'Position',[100 450 850 100])
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);