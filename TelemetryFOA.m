function DataRate = TelemetryFOA (candidateArchitecture)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: Telemetry FOA
%Description: Outputs the projected data rates based on the telemetry band
%amd comms network.
%Inputs: candidateArchitecture (The design of the system)
%Outputs: Data Rate (bps) (1x3 vector with data rates at the ends of the three
%phases)
%Author: Vincent Haight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Parse Variables
TelemetryBand = candidateArchitecture.Telemetry;
CommNetwork = candidateArchitecture.Communications;

%Phase Distances
S1 = 100;%(Au)Distance from Earth to Termination Shock
S1 = S1*1.496e11; %(m)

S2 = 123;%(Au)Distance from Earth to HelioPause
S2 = S2*1.496e11;%(m)

S3 = 150;%(Au)Distance from Earth to Lifecycle End
S3 = S3*1.496e11;%(m)

%Depend on Telemetry Band
if isequal(TelemetryBand,'Ka')
    LaDb = 0.116;%Atmospheric Loss file:///C:/Users/haigh/AppData/Local/Temp/06_Reid_chapt6.pdf pg268
    Lambda = 1.575 / 100; %wavelength (m)
elseif isequal(TelemetryBand,'X')
    Lambda = 3.025 / 100; %wavelength (m)
    LaDb = 0.037;%Atmospheric Loss file:///C:/Users/haigh/AppData/Local/Temp/06_Reid_chapt6.pdf pg268
elseif isequal(TelemetryBand,'S')
    Lambda = 11.25 / 100; %wavelength (m)
    LaDb = 0.033;%Atmospheric Loss file:///C:/Users/haigh/AppData/Local/Temp/06_Reid_chapt6.pdf pg268
else 
    disp('Telemetry Band must be in List (Ka, X, S)')
    return
end

%Depend on Comm Network
if isequal(CommNetwork,'DSN') %can track at all times [Cost file:///C:/Users/haigh/AppData/Local/Temp/6_NASA_MOCS_2014_10_01_14.pdf pg 14] 
    Dr = 70; %(m) Diameter of recieving antenna
elseif isequal(CommNetwork,'IDSN') %Can only track for ~50% of day 
    Dr = 32; %(m) Diameter of recieving antenna
elseif isequal(CommNetwork,'NSN') %Only Designed for 2m km
    Dr = 13;%(m) Diameter of recieving antenna
elseif isequal(CommNetwork,'ngVLA') %may need further research because it intends to use multiple antennae
    Dr = 18; %(m) Diameter of recieving antenna
else
    disp('Communications Network must be in List (DSN, IDSN, NSN, ngVLA)')
    return
end
    

%Depend on the Antenna
Dt = 3.7;  %(m) Diameter of transmitting antenna (Used Voyager as reference)

%Noise Temperature Ask TA's / Prof Mansell
Ts = 290; %(k) found by googling but Im not confident
TsDb = 10*log10(Ts);

%Pointing Loss
Lp = 1; %Should change with more research
LpDb = 10*log10(Lp);

%Eb/No
Eb_No_Req = 10; %Ideal energy per bit / spectral noise density (AAE590 lec6 pg7) in the future this will depend on the comm network
Eb_No = 2 * Eb_No_Req; %Should be double the required rate for safety
Eb_NoDb = 10*log10(Eb_No);%Decibel Value of the energy per bit to noise density

%Boltzmann Constant
k = 1.38e-23; %Boltzmann Constant
kDb = 10* log10(k);

%Transmitter Gain
TranEff = 0.55; %Typical Transmitter efficiency (google)
Gt = TranEff * (pi * Dt / Lambda)^2; %The Transmitter Gain
GtDb = 10*log10(Gt);

%Line Loss 
Ll = 0.95; %typical Line loss percent according to quick google search
LlDb = 10*log10(Ll);



%Power
P = 20; %(W) Reference Power from Voyager 2 ~20 Watts
PDb = 10 * log10(P);

%Free Space Loss
Ls1 = (Lambda / 4 / pi / S1)^2;
Ls1Db = 10*log10(Ls1);
Ls2 = (Lambda / 4 / pi / S2)^2;
Ls2Db = 10*log10(Ls2);
Ls3 = (Lambda / 4 / pi / S3)^2;
Ls3Db = 10*log10(Ls3);

%Receiver Gain
RecEff = 0.55; %typical receive antenna efficiency (AAE590 lec6 pg7)
Gr = pi^2 * Dr^2 * RecEff / Lambda^2;
GrDb = 10*log10(Gr);

R1Db = PDb + LlDb + GtDb + Ls1Db +LaDb + GrDb + LpDb - kDb -TsDb - Eb_NoDb;
R2Db = PDb + LlDb + GtDb + Ls2Db +LaDb + GrDb + LpDb - kDb -TsDb - Eb_NoDb;
R3Db = PDb + LlDb + GtDb + Ls3Db +LaDb + GrDb + LpDb - kDb -TsDb - Eb_NoDb;

DataRate(1) = 10^(R1Db/10);
DataRate(2) = 10^(R2Db/10);
DataRate(3) = 10^(R3Db/10);
