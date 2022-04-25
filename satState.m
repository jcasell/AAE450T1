function xk1 = satState(xk, u)
uk = [u(1), u(2), u(3)];
% Ts = u(4);

I1 = 396.2;
I2 = 1867;
I3 = 1987.8;

J1 = (I3 - I2) / I1;
J2 = (I1 - I3) / I2;
J3 = (I2 - I1) / I3;

xk1_1 = xk(1) - J1*xk(2)*xk(3) / I1 + uk(1) / I1;
xk1_2 = xk(2) - J2*xk(3)*xk(2) / I2 + uk(2) / I2;
xk1_3 = xk(3) - J3*xk(1)*xk(2) / I3 + uk(3) / I3;

b1 = xk(4);
b2 = xk(5);
b3 = xk(6);
b4 = xk(7);

xk1_4 = xk(4) + .5*(xk(1)*b4 - xk(2)*b3 + xk(3)*b2);
xk1_5 = xk(5) + .5*(xk(1)*b3 + xk(2)*b4 - xk(3)*b1);
xk1_6 = xk(6) + .5*(-xk(1)*b2 + xk(2)*b1 + xk(3)*b4);
xk1_7 = xk(7) - .5*(xk(1)*b1 + xk(2)*b2 + xk(3)*b3);

xk1 = [xk1_1; xk1_2; xk1_3; xk1_4; xk1_5; xk1_6; xk1_7];

