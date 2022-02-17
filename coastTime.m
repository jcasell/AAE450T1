function [totalTime,ENATime,LYATime] = coastTime(r0, v0,departFpa)
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

ENARad = 250*au2km;
LYARad = 300*au2km;
ENATime = detTof(phase2R,phase2V,250,phase2Fpa);
[ENAV,ENAFpa] = getFPA(phase2R,phase2V,ENARad,phase2Fpa);
LYATime = detTof(ENARad,ENAV,LYARad,ENAFpa);

%phase3Time = detTof(phase2R,phase2V,phase3R,phase2Fpa);
phase3Time = 35-phase2Time-phase1Time;
%[phase3V, phase3Fpa] = getFPA(phase2R,phase2V,phase3R, phase2Fpa);

phase3Dist = time2dist(phase2R,phase2V, phase3Time, phase2Fpa);
fprintf("Final Distance: %.4f km",phase3Dist);
totalTime = [phase1Time, phase2Time, phase3Time];