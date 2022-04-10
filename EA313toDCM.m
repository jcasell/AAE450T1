function C_DCM = EA313toDCM(theta_1, theta_2, theta_3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: EA313toDCM
%Description: Calculates DCM of a 3-1-3 angle sequence
%Inputs: theta_1, theta_2, theta_3 (Euler Angles)
%Outputs: C_DCM (Direction Cosine Matrix of angle sequence)
%Author: Brendan Jones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R_3_i = [cos(theta_1), sin(theta_1), 0; -sin(theta_1), cos(theta_1), 0; 0, 0, 1];
R_1 = [1, 0, 0; 0, cos(theta_2), sin(theta_2); 0, -sin(theta_2), cos(theta_2)];
R_3_f = [cos(theta_3), sin(theta_3), 0; -sin(theta_3), cos(theta_3), 0; 0, 0, 1];
C_DCM = R_3_f*R_1*R_3_i;
end