function totalTime = coastTime(r0, v0,departFpa)
%Function to calculate time spent in each mission phase
%Take as input initial position (r0), initial velocity (v0), and initial flight
%path angle (departFPA). Output is time spent in each phase measured in
%Julian years. Phase distances are assigned on lines 8-10

au2km = 149597870.691; %Converts AU to kilometers

phase1R = 75*au2km;
phase2R = 120*au2km;
%phase3R = 150*au2km;

phase1Time = detTof(r0,v0,phase1R, departFpa);
[phase1V, phase1Fpa] = getFPA(r0,v0,phase1R, departFpa);

phase2Time = detTof(phase1R,phase1V,phase2R,phase1Fpa);
[phase2V, phase2Fpa] = getFPA(phase1R,phase1V,phase2R, phase1Fpa);

%phase3Time = detTof(phase2R,phase2V,phase3R,phase2Fpa);
phase3Time = 35-phase2Time;

totalTime = [phase1Time, phase2Time, phase3Time];