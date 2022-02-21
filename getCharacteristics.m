function [rad_list,planet1,planet2] = getCharacteristics(options)
%% Get Characteristics Function
% This function will take in the trajectory options and return the orbit
% radii 
% 
% Inputs: options - trajectory option
%
% Outputs: rad_list - vector of orbit radii for planets being used
%          planet1/2 - names of planets used in grav assist
%
%% Options
switch options
    case {"MarsJup","MarsJupO"}
        a1 = 227944135; %Mars [km]
        a2 = 778279959; %Jupiter [km]
        planet1 = "Mars";
        planet2 = "Jupiter";
    case {"JupSat","JupSatO"}
        a1 = 778279959; %Jupiter [km]
        a2 = 1427387908; %Saturn [km]
        planet1 = "Jupiter";
        planet2 = "Saturn";
end
rad_list = [a1,a2];
end