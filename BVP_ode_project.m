function dydt = BVP_ode_project(t,y)

I1 = 396.2;
I2 = 1867;
I3 = 1987.8;

J1 = (I3 - I2) / I1;
J2 = (I1 - I3)/I2;
J3 = (I2 - I1)/I3;

w1 = y(1);
w2 = y(2);
w3 = y(3);
lam1 = y(4);
lam2 = y(5);
lam3 = y(6);

dydt = y(7) * [-J1 * w2 * w3 - lam1/I1^2;-J2 * w3 * w1 - lam2/I2^2;-J3 * w1 * w2 - lam3/I3^2; J2 * w3 * lam2 + J3 * w2 *lam3; J1 * w1 * lam1 + J3 * w1 *lam3; J1 * w2 * lam1 + J2 * w1 *lam2; 0];

end