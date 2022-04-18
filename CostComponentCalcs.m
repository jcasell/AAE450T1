clc
clear

m_instr = 42.5; %Mass in kg of instruments
power_instr = 54.4; %Power in W of instruments
m_spacecraft = m_instr / 0.15;
power_spacecraft = power_instr / 0.22;

%All Costs in F2022 Millions

%% Instrument Cost and See
MAG_cost = 10.43; MAG_sdev = 0.28*MAG_cost;
PLS_cost = 23.3; PLS_sdev = 0.29*PLS_cost;
PUI_cost = 17.09; PUI_sdev = 0.29*PUI_cost;
PWS_cost = 18.34; PWS_sdev = 0.29*PWS_cost;
EPS_cost = 13.97; EPS_sdev = 0.29*EPS_cost;
CRS_cost = 18.88; CRS_sdev = 0.29*CRS_cost;
ENA_cost = 28.95; ENA_sdev = 0.29*ENA_cost;

%Vector For Cost
costInst = [MAG_cost,PLS_cost,PUI_cost,PWS_cost,EPS_cost,CRS_cost,ENA_cost];


%% Spacecraft Component Cost Calculations

%Thermal Control Rec and NRec
costThermNRec = 1.29*(646*(m_spacecraft*0.06)^0.684)/10^3;
costThermRec = 1.29*(22.6*(m_spacecraft*0.06))/10^3;

%ADCS Rec and NRec
costAttNRec = 1.29*(324*(m_spacecraft*0.06))/10^3;
costAttRec = 1.29*(795*(m_spacecraft*0.06)^0.593)/10^3;


%Electrical Cost
costElecRec = 2*108;

%Communications Cost
costCommNRec = 1.29*(618*(m_spacecraft*0.07))/10^3;
costCommRec = 1.29*(189*(m_spacecraft*0.07))/10^3;

costDSNRec = 17.805;

%% Kick Stage Cost
costKickRec = (7.01+5.73);

%% Randomize Bus Cost through Distribution

costBusNRec = costThermNRec + costAttNRec
costBusRec = costThermRec + costAttRec + costElecRec + costKickRec;

%% IAT Cost
costIATRec = 0.195*(costBusRec+costCommNRec+costInst);
costIATNRec = 0.124*(costBusNRec+costCommRec);

%% Randomize Vehicle Cost through Distribution
costVehNRec = costBusNRec + costIATRec + costCommNRec;
costVehRec = costBusRec + costIATNRec + costInst + costCommRec;

%% Program Level, AGE, and LOOS cost
costProgNRec = 0.357*(costVehNRec+costIATNRec);
costProgRec = 0.320*(costVehRec+costIATRec);
sdevProgNRec = 0.5*costProgNRec;
sdevProgRec = 0.4*costProgRec;

costProg = costProgNRec + costProgRec;

LOOScost = 1.29*(5.85+40);
AGEcost = 1.29*(0.432*(costBusNRec*10^3/1.29)^0.907+2.244)/10^3;

%Ops Cost
%Table 11-25 Ops Cost Estimate
%Keep full team for 1 year of maneuvers, cut extra staff for last 30 years
techCount = 6;
engCount = 34-6;
engCount_cut = 2;
techCount_cut = 1;
opsCostexp = (1.29*1*(techCount*150+engCount*200) + 1.29*34*(techCount_cut*150+engCount_cut*200))/10^3;

costICHot = 

%% Total Cost Calculation
cost = (costVehNRec+costVehRec+costProg+LOOScost+AGEcost+opsCostexp+costDSN +costICHot);