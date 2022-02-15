function totalTime = coastTimeMod(r0, v0,beta,fpa0)
%Function to calculate time spent in each mission phase
%Take as input initial position (r0), initial velocity (v0), and initial flight
%path angle (departFPA). Output is time spent in each phase measured in
%Julian years. Phase distances are assigned on lines 8-10

au2km = 149597870.691; %Converts AU to kilometers

phase1R = 75*au2km;
phase2R = 120*au2km;
%phase3R = 150*au2km;

[phase1Time, phase1V,fpa1] = modTof(r0,v0,phase1R,beta,fpa0);
%[phase1V, phase1Fpa] = getFPA(r0,v0,phase1R, departFPA);

[phase2Time, phase2V,fpa2] = modTof(phase1R,phase1V,phase2R,beta,fpa1);
%[phase2V, ~] = getFPA(phase1R,phase1V,phase2R, phase1Fpa);

%[phase3Time, ~,~] = modTof(phase2R,phase2V,phase3R,beta,fpa2);

phase3Time = 35-phase2Time;

totalTime = [phase1Time, phase2Time, phase3Time];