function [DeltaV_kms] = electricProp(candidateArchitecture, m_spacecraft)

% function Data = ElectricProp(totalTime,m_spacecraft)
totalTime = [7.57,1.57,3.142];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: electricProp
%Description: Outputs delta-V provided by hall thruster assuming a
%continuous burn at the thruster's discharge power over phases 2 and 3.
%Inputs: Candidate Architecture (hall thruster), Spacecraft mass
%Outputs: delta-V (km/s)
%Authors: Thomas Beimrohr, Elijah Harris
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

km2au = 1/149597870.691; %Converts AU to kilometers
au2km = 149597870.691;

phase1R = 75*au2km;
phase2R = 90*au2km;
phase3R = 120*au2km;
%Convert Phase time to Seconds
t1 = totalTime(1)*365*24*3600; % [s]
t2 = totalTime(2)*365*24*3600; % [s]
t3 = totalTime(3)*365*24*3600; % [s]

g = 9.81;% [m/s]
eta = .5;
% Busek BHT-600 Hall thruster specifications
if candidateArchitecture.Propulsion == "BHT_600"
    T = (39/1000);  % Thrust [N]
    P = 600;        % Nominal discharge power [W]
    ISP = 1500;     % Specific impulse [s]
    M = 2.8;        % Mass [kg]
elseif candidateArchitecture.Propulsion == "BHT_100"
    T = (7/1000);   % [N]
    P = 100;        % [W]
    ISP = 1000;     % [s]
    M = 1.16;       % [kg]
else
    T = (39/1000);   % [N]
    P = 600;        % [W]
    ISP = 1500;     % [s]
    M = 2.8;       % [kg]
end

Pjet = P*eta;
UE = Pjet*2/T;      % [m/s]
Mdot = T/UE;        % [kg/s]

Mprop2 = Mdot*t2; % Mass of propellant needed to burn continuously during phase 2 [kg]
m_craft1a = m_spacecraft + Mprop2 + M;
delta_V1a = ISP*g*log(m_craft1a/(m_spacecraft+M)); % [m/s]
lambda2 = Mprop2/(Mprop2+M);    % Propellant mass fraction of system

Mprop3 = Mdot*t3; % [kg]
m_craft2a = m_spacecraft + Mprop3 + M;
delta_V2a = ISP*g*log(m_craft2a/(m_spacecraft+M)); % [m/s]
lambda3 = Mprop3/(Mprop3+M);

figure(1)
Name = ["Phase 1";"Phase 2"];
Time_of_Flight_years = [totalTime(2);totalTime(3)];
Propellant_Mass = [Mprop2;Mprop3];
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
end