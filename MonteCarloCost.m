function cost = MonteCarloCost()

m_instr = 42.5; %Mass in kg of instruments
power_instr = 54.4; %Power in W of instruments
m_spacecraft = m_instr / 0.15;
power_spacecraft = power_instr / 0.22;

%All Costs in F2022 Millions

%% Instrument Cost and See
% New Restructured Cost, limited life to 15 for non ENA, ENA is 35
MAG_cost = 6.43; MAG_sdev = 0.28*MAG_cost;
PLS_cost = 20.16; PLS_sdev = 0.29*PLS_cost;
PUI_cost = 14.79; PUI_sdev = 0.29*PUI_cost;
PWS_cost = 15.86; PWS_sdev = 0.29*PWS_cost;
EPS_cost = 12.09; EPS_sdev = 0.29*EPS_cost;
CRS_cost = 16.33; CRS_sdev = 0.29*CRS_cost;
ENA_cost = 25.17; ENA_sdev = 0.29*ENA_cost;

%Vector For Cost
instMu = [MAG_cost,PLS_cost,PUI_cost,PWS_cost,EPS_cost,CRS_cost,ENA_cost];
instSigma = [MAG_sdev,PLS_sdev,PUI_sdev,PWS_sdev,EPS_sdev,CRS_sdev,ENA_sdev];
costInst = 0;

%Instrument Cost Calculation
for i = 1:length(instMu)
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
costElecRec = 2*108;
costElecMax = 2*118;
costElecMin = 2*93;
nuclearLaunch = 1.10 * 40.3;
elecDist = makedist('Triangular','A',costElecMin,'B',costElecRec,'C',costElecMax);

%Communications Cost
costCommNRec = 1.29*(618*(m_spacecraft*0.07))/10^3;
costCommRec = 1.29*(189*(m_spacecraft*0.07))/10^3;
sdevCommNRec = 0.38*costCommNRec;
sdevCommRec = 0.39*costCommRec;

costDSNRec = 17.805;
costDSNMax = 20;
costDSNMin = 15;
DSNdist = makedist('Triangular','A',costDSNMin,'B',costDSNRec,'C',costDSNMax);
costDSN = random(DSNdist);

%% Kick Stage Cost
costKickRec = (7.01+5.73);
sdevKickRec = .22*costKickRec;

%% Randomize Bus Cost through Distribution

costBusNRec = normrnd(costThermNRec,sdevThermNRec) + normrnd(costAttNRec,sdevAttNRec);
costBusRec = normrnd(costThermRec,sdevThermRec) + normrnd(costAttRec,sdevAttRec) + random(elecDist) + normrnd(costKickRec,sdevKickRec);

%% IAT Cost
costIATRec = 0.195*(costBusRec+normrnd(costCommNRec,sdevCommNRec)+costInst);
costIATNRec = 0.124*(costBusNRec+normrnd(costCommRec,sdevCommRec));
sdevIATRec = 0.34*costIATRec;
sdevIATNRec = 0.42*costIATNRec;
IATRec = normrnd(costIATRec,sdevIATRec);
IATNRec = normrnd(costIATNRec,sdevIATNRec);

%% Randomize Vehicle Cost through Distribution
costVehNRec = costBusNRec + IATNRec + normrnd(costCommNRec,sdevCommNRec);
costVehRec = costBusRec + IATRec + costInst + normrnd(costCommRec,sdevCommRec);

%% Program Level, AGE, and LOOS cost
costProgNRec = 0.357*(costVehNRec+costIATNRec);
costProgRec = 0.320*(costVehRec+costIATRec);
sdevProgNRec = 0.5*costProgNRec;
sdevProgRec = 0.4*costProgRec;

costProg = normrnd(costProgNRec,sdevProgNRec) + normrnd(costProgRec,sdevProgRec);

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
opsCostMin = 0.9*opsCostexp;
opsCostMax = 1.1*opsCostexp;
opsDist = makedist('Triangular','A',opsCostMin,'B',opsCostexp,'C',opsCostMax);
opsCost = random(opsDist);

%Additional Objective Cost
%IC-HOT
ICmass = 24;
ICbusRec = 1064+35.5*(ICmass)^1.261;
ICbusSDEV = 3696;

ICbus = normrnd(ICbusRec,ICbusSDEV)*1.29*10^-3;
ICpay = 0.4*ICbus;
ICiat = 0.139*ICbus;
ICprog = 0.229*ICbus;
ICloos = 0.061*ICbus;
ICgse = 0.066*ICbus;
ICcost = ICbus+ICpay+ICiat+ICprog+ICloos+ICgse;


%% Total Cost Calculation
cost = (costVehNRec+costVehRec+costProg+nuclearLaunch+LOOScost+AGEcost+opsCost+costDSN+ICcost);

end