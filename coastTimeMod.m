function totalTime = coastTimeMod(r0, v0,departFPA,beta)
%Function to calculate time spent in each mission phase
%Take as input initial position (r0), initial velocity (v0), and initial flight
%path angle (departFPA). Output is time spent in each phase measured in
%Julian years. Phase distances are assigned on lines 8-10

au2km = 149597870.691; %Converts AU to kilometers

phase1R = 113*au2km;
phase2R = 120*au2km;
phase3R = 150*au2km;

phase1Time = modTof(r0,v0,phase1R,beta);
[phase1V, phase1Fpa] = getFPA(r0,v0,phase1R, departFPA);

phase2Time = modTof(phase1R,phase1V,phase2R,beta);
[phase2V, ~] = getFPA(phase1R,phase1V,phase2R, phase1Fpa);

phase3Time = modTof(phase2R,phase2V,phase3R,beta);

totalTime = [phase1Time, phase2Time, phase3Time];