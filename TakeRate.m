function Data = TakeRate (Dt, P, S)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: TakeRate
%Description: Outputs the projected data per second based on the antenna
%diameter, power input and distance from Earth
%Inputs: Dt (Transmitting Diameter), P (Power input to the telemetry
%system), S (Distance From Earth),
%PhaseTime in seconds
%Outputs: Data (bits/s)
%Author: Vincent Haight
%Contributer: Lauren Risany
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


C = 3e8; % the speed of light in m/s
LaDb = 0.116;%Atmospheric Loss pg268 https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwi9-7_Ostr2AhVBBs0KHfPeDvkQFnoECAsQAQ&url=https%3A%2F%2Fdescanso.jpl.nasa.gov%2Fmonograph%2Fseries10%2F06_Reid_chapt6.pdf&usg=AOvVaw3KRDBuqDfCGQs9DjpbUuuz
Lambda = 1.575 / 100; %wavelength (m)
f = C / Lambda; % freqency of signal in Hz
Dr = 32; %(m) Diameter of recieving antenna

%Noise Temperature
Ts = 7.277; %(k) pg269 https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwi9-7_Ostr2AhVBBs0KHfPeDvkQFnoECAsQAQ&url=https%3A%2F%2Fdescanso.jpl.nasa.gov%2Fmonograph%2Fseries10%2F06_Reid_chapt6.pdf&usg=AOvVaw3KRDBuqDfCGQs9DjpbUuuz
TsDb = 10*log10(Ts);

%Pointing Loss (This needs to be updated as we increase our understanding
%of controls)
e = 1; % antenna pointing offset
theta = 1; % antenna beamwidth in degrees, assumed from Voyager 2
LpDb = -12*((e / theta)^2);

%Eb/No
Eb_No_ReqDb = 10.5; % (DB) energy per bit / spectral noise density based on SMAD fig 16-16 pg 474 with error rate 10^-6
Eb_NoDb = 3 + Eb_No_ReqDb; %Should be double the required rate for safety equivalent to +3 DB

%Boltzmann Constant
k = 1.38e-23; %Boltzmann Constant
kDb = 10* log10(k);

%Transmitter Gain
TranEff = 0.55; %Typical Transmitter efficiency (google)
Gt = TranEff * (pi * Dt / Lambda)^2; %The Transmitter Gain
GtDb = 10*log10(Gt);

%Line Loss 
Ll = 0.95; %typical Line loss percent according to quick google search Confirmed by Mansell
LlDb = 10*log10(Ll);

%Power
% P = 20; %(W) Reference Power from Voyager 2 ~20 Watts
PDb = 10 * log10(P);

%Receiver Gain in decibles 
RecEff = 0.55; %typical receive antenna efficiency (AAE590 lec6 pg7)
%Past Calc:Gr = pi^2 * Dr^2 * RecEff / Lambda^2; 
%         GrDb = 10*log10(Gr);
% Source: https://engineering.purdue.edu/AAECourses/aae450/2008/spring/report_archive/report2nddraftuploads/appendix/avionics/A.2.2.3%20Link%20Budget%20Analysis.doc
GrDb = -159.59 + 20*log10(Dr) + 20*log10(f) + 10*log10(RecEff);

% %Outputs
S = S*1.496e11; %(m)
Data = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, S, Lambda);
end

function Rate = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, S, Lambda)

    %Free Space Loss
    Ls = (Lambda / 4 / pi / S)^2;
    LsDb = 10*log10(Ls);

    %Data Rate
    RDb = PDb + LlDb + GtDb + LsDb + LaDb + GrDb + LpDb - kDb - TsDb - Eb_NoDb;
    Rate = 10^(RDb/10);
end
