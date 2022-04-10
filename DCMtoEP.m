function [e_param] = DCMtoEP(C_DCM)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function Name: DCMtoEP
%Description: Calculates Euler Parameters from DCM
%Inputs: C_DCM (Direction Cosine Matrix of angle sequence)
%Outputs: 
%           e_param - Euler Parameter
%Author: Brendan Jones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Problem 1 (b.3)

e_param_1_sq = 0.25 * (1 + 2 * C_DCM(1,1) - trace(C_DCM));
e_param_2_sq = 0.25 * (1 + 2 * C_DCM(2,2) - trace(C_DCM));
e_param_3_sq = 0.25 * (1 + 2 * C_DCM(3,3) - trace(C_DCM));
e_param_4_sq = 0.25 * (1 + trace(C_DCM));

%Put these Euler values into vector and find the maximum value
e_param_sq_vec = [e_param_1_sq ;e_param_2_sq;e_param_3_sq;e_param_4_sq];
e_param_sq_max = max(e_param_sq_vec);
e_param_sq_max_index = find(e_param_sq_vec == e_param_sq_max); 

%Find Each Parameter based on the largest value calculated above
if(e_param_sq_max_index == 1) %case 1
    e_param_1 = sqrt(e_param_1_sq);
    e_param_2 = ((C_DCM(1,2)+C_DCM(2,1)) / 4) / e_param_1;
    e_param_3 = ((C_DCM(3,1)+C_DCM(1,3)) / 4) / e_param_1;
    e_param_4 = ((C_DCM(2,3)-C_DCM(3,2)) / 4) / e_param_1;
    e_param = [e_param_1; e_param_2; e_param_3; e_param_4];
    
elseif(e_param_sq_max_index == 2) %case 2
    e_param_2 = sqrt(e_param_2_sq);
    e_param_1 = ((C_DCM(1,2)+C_DCM(2,1)) / 4) / e_param_2;
    e_param_3 = ((C_DCM(2,3)+C_DCM(3,2)) / 4) / e_param_2;
    e_param_4 = ((C_DCM(3,1)-C_DCM(1,3)) / 4) / e_param_2;
    e_param = [e_param_1; e_param_2; e_param_3; e_param_4];
    
elseif(e_param_sq_max_index == 3) %case 3
    e_param_3 = sqrt(e_param_3_sq);
    e_param_1 = ((C_DCM(3,1)+C_DCM(1,3)) / 4) / e_param_3;
    e_param_2 = ((C_DCM(2,3)+C_DCM(3,2)) / 4) / e_param_3;
    e_param_4 = ((C_DCM(1,2)-C_DCM(2,1)) / 4) / e_param_3;
    e_param = [e_param_1; e_param_2; e_param_3; e_param_4];
    
else %case 4
    e_param_4 = sqrt(e_param_4_sq);
    e_param_1 = ((C_DCM(2,3)-C_DCM(3,2)) / 4) / e_param_4;
    e_param_2 = ((C_DCM(3,1)-C_DCM(1,3)) / 4) / e_param_4;
    e_param_3 = ((C_DCM(1,2)-C_DCM(2,1)) / 4) / e_param_4;
    e_param = [e_param_1; e_param_2; e_param_3; e_param_4];
    
end


end