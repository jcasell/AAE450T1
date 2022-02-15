function [DeltaV_kms,m_spacecraft_arr] = electricProp(candidateArchitecture, totalTOF, m_spacecraft)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: electricProp
%Description: Outputs delta-V provided by hall thruster assuming a
%continuous burn at the thruster's discharge power over phases 2 and 3.
%Inputs: Candidate Architecture (hall thruster), Spacecraft mass
%Outputs: delta-V (km/s)
%Authors: Thomas Beimrohr, Elijah Harris
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% totalTOF = [7.57,1.57,3.142];  % DEBUG TOF input

km2au = 1/149597870.691; %Converts AU to kilometers
au2km = 149597870.691;

phase1R = 75*au2km;
phase2R = 90*au2km;
phase3R = 120*au2km;
%Convert Phase time to Seconds
t1 = totalTOF(1)*365*24*3600; % [s]
t2 = totalTOF(2)*365*24*3600; % [s]
t3 = totalTOF(3)*365*24*3600; % [s]

g = 9.81;   % [m/s^2]
eta = .5;
% Busek BHT-X00 Hall thruster specifications
if candidateArchitecture.Propulsion == "BHT_600"
    T = 39/1000;  % Thrust [N]
    P = 600;        % Nominal discharge power [W]
    ISP = 1500;     % Specific impulse [s]
    m_inert = 2.8;        % Mass [kg]
elseif candidateArchitecture.Propulsion == "BHT_100"
    T = 7/1000;   % [N]
    P = 100;        % [W]
    ISP = 1000;     % [s]
    m_inert = 1.16;       % [kg]
else
    T = 39/1000;   % [N]
    P = 600;        % [W]
    ISP = 1500;     % [s]
    m_inert = 2.8;       % [kg]
end

Pjet = P*eta;
UE = Pjet*2/T;      % [m/s]
Mdot = T/UE;        % [kg/s]

m_prop = zeros(1,3);
deltaV = zeros(1,3);
lambda = zeros(1,3);    % This should be estimated, not calculated

% if commented out: assume no burn in phase 3 (poor solar panel performance)
m_prop(3) = Mdot*t3; % " during phase 3 [kg]
deltaV(3) = ISP*g*log((m_spacecraft + m_inert + m_prop(3))/(m_spacecraft + m_inert)); % [m/s]
lambda(3) = m_prop(3)/(m_prop(3) + m_inert);
% 
% If commented out: assume no burn in phase 2 (poor solar panel performance)
m_prop(2) = Mdot*t2; % " during phase 2 [kg]
deltaV(2) = ISP*g*log((m_spacecraft + m_inert + m_prop(2) + m_prop(3))/(m_spacecraft + m_inert + m_prop(3))); % [m/s]
lambda(2) = m_prop(2) / (m_prop(2) + m_inert);    % Propellant mass fraction of system
%
m_prop(1) = Mdot*t1; % Mass of propellant needed to burn continuously during phase 1 [kg]
deltaV(1) = ISP*g*log((m_spacecraft + m_inert + m_prop(1) + m_prop(2) + m_prop(3))/(m_spacecraft + m_inert + m_prop(2) + m_prop(3))); % [m/s]
lambda(1) = m_prop(1) / (m_prop(1) + m_inert);
% Total spacecraft mass in each phase when using electric propulsion
m_spacecraft_arr = [m_spacecraft + m_inert + m_prop(1) + m_prop(2) + m_prop(3); m_spacecraft + m_inert + m_prop(2) + m_prop(3); m_spacecraft + m_inert + m_prop(3)];

figure(1)
Name = ["Phase 1";"Phase 2";"Phase 3"];
Time_of_Flight_years = transpose(totalTOF);
Propellant_Mass = transpose(m_prop);
Spacecraft_Mass = m_spacecraft_arr;
DeltaV_kms = transpose(deltaV./1000);
Lambda = transpose(lambda);
% Time_of_Flight_years = [totalTOF(1);totalTOF(2);totalTOF(3)];
% Propellant_Mass = [m_prop(1);m_prop(2);m_prop(3)];
% Spacecraft_Mass = [m_spacecraft + m_inert + m_prop(1);m_spacecraft + m_inert + m_prop(2);m_spacecraft + m_inert + m_prop(3)];
% DeltaV_kms = [deltaV(1)/1000;deltaV(2)/1000;deltaV(3)/1000];
% Lambda = [lambda(1);lambda2;lambda3];
T = table(Name,Time_of_Flight_years,Propellant_Mass,Spacecraft_Mass,DeltaV_kms,Lambda);
TString = evalc('disp(T)');
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
FixedWidth = get(0,'FixedWidthFontName'); set(gcf,'Position',[100 100 600 100]) 
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
end