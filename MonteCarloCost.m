m_instr = 42.5; %Mass in kg of instruments
power_instr = 54.4; %Power in W of instruments
m_spacecraft = m_instr / 0.15;
power_spacecraft = power_instr / 0.22;

%% Instrument Cost and See
MAG_cost = 10.43; MAG_sdev = 0.28*MAG_cost;
PLS_cost = 23.3; PLS_sdev = 0.29*PLS_cost;
PUI_cost = 17.09; PUI_sdev = 0.29*PUI_cost;
PWS_cost = 18.34; PWS_sdev = 0.29*PWS_cost;
EPS_cost = 13.97; EPS_sdev = 0.29*EPS_cost;
CRS_cost = 18.88; CRS_sdev = 0.29*CRS_cost;
ENA_cost = 28.95; ENA_sdev = 0.29*ENA_cost;

%% Spacecraft Component Cost Calculations

%Thermal Control Rec and NRec
costThermNRec = 1.29*(646*(m_spacecraft*0.06)^0.684);
costThermRec = 1.29*(22.6*(m_spacecraft*0.06));
sdevThermNRec = 0.22*costThermNRec;
sdevThermRec = 0.21*costThermRec;

%ADCS Rec and NRec
costAttNRec = 1.29*(324*(m_spacecraft*0.06));
costAttRec = 1.29*(795*(m_spacecraft*0.06)^0.593);
sdevAttNRec = 0.44*costAttNRec;
sdevAttRec = 0.36*costAttRec;

%Electrical Cost

%Communications Cost

%% Kick Stage Cost

%% IAT Cost

%% Program Level, AGE, and LOOS cost

