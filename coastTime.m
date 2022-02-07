function [phase1Time, phase2Time, phase3Time] = coastTime(r0, v0,departFPA)
%Function to calculate time spent in each mission phase
%Take as input initial position (r0), initial velocity (v0), and initial flight
%path angle (departFPA). Output is time spent in each phase measured in
%Julian years. Phase distances are assigned on lines 8-10

au2km = 149597870.691; %Converts AU to kilometers

phase1R = 113*au2km;
phase2R = 120*au2km;
phase3R = 150*au2km;

[phase1Time, phase1Fpa, phase1V] = detTof(r0,v0,phase1R, departFPA);
[phase2Time, phase2Fpa, phase2V] = detTof(phase1R,phase1V,phase2R, phase1Fpa);
[phase3Time, ~, ~] = detTof(phase2R,phase2V,phase3R, phase2Fpa);

phase1Time = phase1Time / (3600 * 24 * 365.25); %Convert each time to JY
phase2Time = phase2Time / (3600 * 24 * 365.25);
phase3Time = phase3Time / (3600 * 24 * 365.25);
