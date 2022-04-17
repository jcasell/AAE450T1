function bcs = boundary_conditions_project(ya,yb)

I1 = 396.2;
I2 = 1867;
I3 = 1987.8;

J1 = (I3 - I2) / I1;
J2 = (I1 - I3)/I2;
J3 = (I2 - I1)/I3;

bcs = [ya(1) - .001;     ya(2) - .001 ;ya(3) - .001;     yb(1);     yb(2);    yb(3) - .5236;  (-yb(4)/I1)^2 + (-yb(5)/I2)^2 + (-yb(6) / I3)^2 + yb(4)*(- J1 * yb(2) * yb(3) - yb(4)/I1^2) + yb(5)*(- J2 * yb(3)*yb(1) - yb(5)/I2^2) + yb(6)*(- J3*yb(1)*yb(2) - yb(6)/I3^2) ];

end