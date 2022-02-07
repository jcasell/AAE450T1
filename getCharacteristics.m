function rad_list = getCharacteristics(options)
%% Get Characteristics Function
% This function will take in the trajectory options and return the orbit
% radii 
% 
% Inputs: options - trajectory option
%
% Outputs: rad_list - vector of orbit radii for planets being used
%
%% Options
switch options
    case {"JupNep","JupNepO"}
        a1 = 778279959; %Jupiter [km]
        a2 = 4498337290; %Neptune [km]
    case {"JupSat","JupSatO"}
        a1 = 778279959; %Jupiter [km]
        a2 = 1427387908; %Saturn [km]
end
rad_list = [a1,a2];
end