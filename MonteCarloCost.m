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
instMu = [MAG_cost,PLS_cost,PUI_cost,PWS_cost,EPS_cost,CRS_cost,ENA_cost];
instSigma = [MAG_sdev,PLS_sdev,PUI_sdev,PWS_sdev,EPS_sdev,CRS_sdev,ENA_sdev];
costInst = 0;

%Instrument Cost Calculation
for i = length(instMu)
    costInst = costInst + normrnd(instMu(i),instSigma(i));
end

%% Spacecraft Component Cost Calculations

%Thermal Control Rec and NRec
costThermNRec = 1.29*(646*(m_spacecraft*0.06)^0.684)/10^3;
costThermRec = 1.29*(22.6*(m_spacecraft*0.06))/10^3;
sdevThermNRec = 0.22*costThermNRec;
sdevThermRec = 0.21*costThermRec;

%ADCS Rec and NRec
costAttNRec = 1.29*(324*(m_spacecraft*0.06))/10^3;
costAttRec = 1.29*(795*(m_spacecraft*0.06)^0.593)/10^3;
sdevAttNRec = 0.44*costAttNRec;
sdevAttRec = 0.36*costAttRec;

%Electrical Cost
costElecRec = 2*109;
costElecMax = 2*118;
costElecMin = 2*90;
elecDist = makedist('Triangular','A',costElecMin,'B',costElecRec,'C',costElecMax);

%Communications Cost
costCommRec = 17.805;
costCommMax = 20;
costCommMin = 15;
commDist = makedist('Triangular','A',costCommMin,'B',costCommRec,'C',costCommMax);
costComm = random(commDist);

%% Kick Stage Cost
costKickRec = (7.01 + 5.73);
costKickMax = 20;
costKickMin = 10;
kickDist = makedist('Triangular','A',costKickMin,'B',costKickRec,'C',costKickMax);

%% Randomize Bus Cost through Distribution

costBusNRec = normrnd(costThermNRec,sdevThermNRec) + normrnd(costAttNRec,sdevAttNRec);
costBusRec = normrnd(costThermRec,sdevThermRec) + normrnd(costAttRec,sdevAttRec) + random(elecDist) + random(kickDist);

%% IAT Cost
costIATRec = 0.195*(costBusRec+costComm+costInst);
costIATNRec = 0.124*(costBusNRec);
sdevIATRec = 0.34*costIATRec;
sdevIATNRec = 0.42*costIATNRec;
IATRec = normrnd(costIATRec,sdevIATRec);
IATNRec = normrnd(costIATNRec,sdevIATNRec);

%% Randomize Vehicle Cost through Distribution
costVehNRec = costBusNRec + IATNRec;
costVehRec = costBusRec + IATRec + costInst + costComm;

%% Program Level, AGE, and LOOS cost
costProgNRec = 0.357*(costVehNRec+costIATNRec);
costProgRec = 0.320*(costVehRec+costIATRec);
sdevProgNRec = 0.5*costProgNRec;
sdevProgRec = 0.4*costProgRec;

costProg = normrnd(costProgNRec,sdevProgNRec) + normrnd(costProgRec,sdevProgRec);

LOOScost = 1.29*5.85;
AGEcost = 1.29*(0.432*(costBusNRec*10^3/1.29)^0.907+2.244)/10^3;

%Ops Cost
%Table 11-25 Ops Cost Estimate
%Keep full team for 1 year of maneuvers, cut extra staff for last 30 years
techCount = 6;
engCount = 34-6;
engCount_cut = 2;
techCount_cut = 1;
opsCostexp = 1.29*1*(techCount*150+engCount*200) + 1.29*34*(techCount_cut*150+engCount_cut*200)/10^3;
opsCostMin = 0.9*opsCostexp;
opsCostMax = 1.1*opsCostexp;
opsDist = makedist('Triangular','A',opsCostMin,'B',opsCostexp,'C',opsCostMax);
opsCost = random(opsDist);

%% Total Cost Calculation
cost = (costVehNRec+costVehRec+costProg+LOOScost+AGEcost+opsCost)*1.3
