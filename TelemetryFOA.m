function Data = TelemetryFOA (candidateArchitecture, PhaseTime)%, EndOfLifeS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: Telemetry FOA
%Description: Outputs the projected data per phase based on the telemetry band
% comms network, phase times and phase distances.
%Inputs: TelemetryBand (Name of telemetry band), CommNetwork (Name of
%Communications network), Instrument (Instrumentation package: A,B or C),
%PhaseTime in seconds
%Outputs: Data (bits) (1x3 vector with data acquired by the ends of the three
%phases)
%Author: Vincent Haight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TelemetryBand = candidateArchitecture.Telemetry;
CommNetwork = candidateArchitecture.Communications;
Instrument = candidateArchitecture.Instruments;

%Convert Phase time to Seconds
PhaseTime = PhaseTime*365*24*3600;

%Phase Distances

S1 = 75;%(Au)Distance from Earth to Termination Shock
S1 = S1*1.496e11; %(m)

S2 = 120;%(Au)Distance from Earth to HelioPause
S2 = S2*1.496e11;%(m)

%S3 = EndOfLifeS; %(m) Distance from Earth at 35 years

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
    Dr = 32; %(m) Diameter of recieving antenna
    Weight = 1; %amount of time contact is posible
elseif isequal(CommNetwork,'IDSN') %Can only track for ~50% of day 
    Dr = 32; %(m) Diameter of recieving antenna
    Weight = 0.5; %amount of time contact is posible
elseif isequal(CommNetwork,'NSN') %Only Designed for 2m km
    Dr = 13;%(m) Diameter of recieving antenna
    Weight = 1; %amount of time contact is posible
elseif isequal(CommNetwork,'ngVLA') %may need further research because it intends to use multiple antennae
    Dr = 18; %(m) Diameter of recieving antenna
    Weight = 0.5; %amount of time contact is posible
else
    disp('Communications Network must be in List (DSN, IDSN, NSN, ngVLA)')
    return
end

%Depend on Instrumentation Package requirements
if isequal(Instrument,"Minimum")
    S3 = 160;%(Au)Distance from Earth to Lifecycle End
elseif isequal(Instrument,"Mid Level")
    S3 = 260;%(Au)Distance from Earth to Lifecycle End
elseif isequal(Instrument,"High Level")
    S3 = 310;%(Au)Distance from Earth to Lifecycle End
end 
S3 = S3*1.496e11;%(m)

%Depend on the Antenna
Dt = 3.7;  %(m) Diameter of transmitting antenna (Used Voyager as reference)

%Noise Temperature
Ts = 15; %(k) According to Prof Mansell (Cryogenically cooled antennae)
TsDb = 10*log10(Ts);

%Pointing Loss
Lp = 1; %Should change with more research
LpDb = 10*log10(Lp);

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
P = 20; %(W) Reference Power from Voyager 2 ~20 Watts
PDb = 10 * log10(P);

%Receiver Gain
RecEff = 0.55; %typical receive antenna efficiency (AAE590 lec6 pg7)
Gr = pi^2 * Dr^2 * RecEff / Lambda^2;
GrDb = 10*log10(Gr);

%Phase 1 Bits
Dist1 = linspace(600000,S1,100); %Breaks the phase 1 distances into 100 slices
MiniTime1 = PhaseTime(1) / 100;%Solves for time per slice
prev = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist1(1), Lambda);%Finds the data rate at the start of the slice
bits1 = 0; %initiates the number of bits in the phase 
for ii = 2:1:100
    current = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist1(ii), Lambda);%Bit rate at the end of the slice
    bits1 = bits1 + (current+prev) / 2 * MiniTime1; %Adds the number of bits this slice to the total
    prev = current;%Stores the bit rate for the beginning of the next slice
end

%Phase 2 Bits
Dist2 = linspace(S1,S2,100);%Breaks the phase 2 distances into 100 slices
MiniTime2 = PhaseTime(2)/100;%Solves for time per slice
prev = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist2(1), Lambda);%Finds the data rate at the start of the phase
bits2 = 0;%initiates the number of bits in the phase 
for ii = 2:1:100
    current = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist2(ii), Lambda);%Finds the data rate at the start of the slice
    bits2 = bits2 + (current+prev) / 2 * MiniTime2;%Adds the number of bits this slice to the total
    prev = current;%Stores the bit rate for the beginning of the next slice
end

%Phase 3 Bits
Dist3 = linspace(S2,S3,100);%Breaks the phase 3 distances into 100 slices
MiniTime3 = PhaseTime(3)/100;%Solves for time per slice
prev = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist3(1), Lambda);%Finds the data rate at the start of the phase
bits3 = 0;%initiates the number of bits in the phase 
for ii = 2:1:100
    current = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist3(ii), Lambda);%Finds the data rate at the start of the slice
    bits3 = bits3 + (current+prev) / 2 * MiniTime3;%Adds the number of bits this slice to the total
    prev = current;%Stores the bit rate for the beginning of the next slice
end

%Outputs
Data = Weight*[bits1,bits2,bits3];
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Reference DSN-Ka 310 Au
% LaDb = 0.116;%Atmospheric Loss file:///C:/Users/haigh/AppData/Local/Temp/06_Reid_chapt6.pdf pg268
% Lambda = 1.575 / 100; %wavelength (m)
% Dr = 32; %(m) Diameter of recieving antenna
% Weight = 1; %amount of time contact is posible
% S3 = 310;%(Au)Distance from Earth to Lifecycle End
% S3 = S3*1.496e11;%(m)
% 
% Gt = TranEff * (pi * Dt / Lambda)^2; %The Transmitter Gain
% GtDb = 10*log10(Gt);
% Gr = pi^2 * Dr^2 * RecEff / Lambda^2;
% GrDb = 10*log10(Gr);
% 
% %Phase 1 Bits
% Dist1 = linspace(600000,S1,100); %Breaks the phase 1 distances into 100 slices
% MiniTime1 = PhaseTime(1) / 100;%Solves for time per slice
% prev = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist1(1), Lambda);%Finds the data rate at the start of the slice
% bits1 = 0; %initiates the number of bits in the phase 
% for ii = 2:1:100
%     current = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist1(ii), Lambda);%Bit rate at the end of the slice
%     bits1 = bits1 + (current+prev) / 2 * MiniTime1; %Adds the number of bits this slice to the total
%     prev = current;%Stores the bit rate for the beginning of the next slice
% end
% 
% %Phase 2 Bits
% Dist2 = linspace(S1,S2,100);%Breaks the phase 2 distances into 100 slices
% MiniTime2 = PhaseTime(2)/100;%Solves for time per slice
% prev = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist2(1), Lambda);%Finds the data rate at the start of the phase
% bits2 = 0;%initiates the number of bits in the phase 
% for ii = 2:1:100
%     current = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist2(ii), Lambda);%Finds the data rate at the start of the slice
%     bits2 = bits2 + (current+prev) / 2 * MiniTime2;%Adds the number of bits this slice to the total
%     prev = current;%Stores the bit rate for the beginning of the next slice
% end
% 
% %Phase 3 Bits
% Dist3 = linspace(S2,S3,100);%Breaks the phase 3 distances into 100 slices
% MiniTime3 = PhaseTime(3)/100;%Solves for time per slice
% prev = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist3(1), Lambda);%Finds the data rate at the start of the phase
% bits3 = 0;%initiates the number of bits in the phase 
% for ii = 2:1:100
%     current = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, Dist3(ii), Lambda);%Finds the data rate at the start of the slice
%     bits3 = bits3 + (current+prev) / 2 * MiniTime3;%Adds the number of bits this slice to the total
%     prev = current;%Stores the bit rate for the beginning of the next slice
% end

% %Outputs
% DataRef = Weight*[bits1,bits2,bits3];
% 
% Data = Data ./ DataRef;

end

function Rate = GetRate(PDb, LlDb, GtDb, LaDb, GrDb, LpDb, kDb, TsDb, Eb_NoDb, S, Lambda)

    %Free Space Loss
    Ls = (Lambda / 4 / pi / S)^2;
    LsDb = 10*log10(Ls);

    %Data Rate
    RDb = PDb + LlDb + GtDb + LsDb + LaDb + GrDb + LpDb - kDb - TsDb - Eb_NoDb;
    Rate = 10^(RDb/10);
end
