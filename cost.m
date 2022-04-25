function f = cost(X,U,e,data)
% Use MVs from k to k+p-1
U1 = U(1:end-1,1);
U2 = U(1:end-1,2);
U3 = U(1:end-1,3);
% Minimize control efforts plus sum of I2 and L2 population
B1 = 50;
 
f = data.Ts*(0.5*(B1*(U1'*U1) + B1*(U2'*U2) + B1*(U3'*U3)));