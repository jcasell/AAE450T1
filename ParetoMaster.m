%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Script Name: ParetoMaster
%Description: Calculates and Plots Pareto for Analysis
%Author: Jeremy Casella
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all

%Define Possible Matrix Options
ComNet = ["DSN" "IDSN" "NSN" "ngVLA"]; %Communication Network Options
Telem = ["Ka" "X" "S"];     %Telemetry Band
Prop = ["Nuclear Thermal" "Chemical" "Solar Sail" "Plasma" "None"];   %Propulsion Options
Power = ["RTG Nuclear" "Solar Panel/Nuclear"];  %Power Source Options
Instr = ["Minimum" "Mid Level" "High Level"];    %Instrumentation Options
Traj = ["JupNep","JupSat","JupNepO","JupSatO"]; %Trajectory Options (O indicates oberth maneuver)
LaunchV = ["SLS" "Falcon Heavy" "Starship" "New Glenn"];    %Launch Vehicle Options
Kick = ["Solid" "Liquid" "Hybrid" "None"];   %Kick Stages Options

%Create Results Table
ResultsRaw = [];

%Create Permutations of Missions
for i1 = ComNet
    for i2 = Telem
        for i3 = Prop
            for i4 = Power
                for i5 = Instr
                    for i6 = Traj
                        for i7 = LaunchV
                            for i8 = Kick
                                candidateArchitecture.Communications = i1;
                                candidateArchitecture.Telemetry = i2;
                                candidateArchitecture.Propulsion = i3;
                                candidateArchitecture.Power = i4;
                                candidateArchitecture.Instruments = i5;
                                candidateArchitecture.Trajectory = i6;
                                candidateArchitecture.LaunchVehicle = i7;
                                candidateArchitecture.Kick = i8;
                                
                                %Call Mission Program\
                                [science, cost, reliability, ttHP] = MissionCalc(candidateArchitecture);

                                %Create Table of Results etc
                                ResultsRaw = [ResultsRaw; [i1 i2 i3 i4 i5 i6 i7 i8 cost science reliability ttHP]];

                            end
                        end
                    end
                end
            end
        end
    end
end

%Parse Table
Results = array2table(ResultsRaw,'VariableNames', {'Communications','Telemetry','Propulsion','Power','Instruments','Trajectory','Launch_Vehicle','Kick_Stages','Cost','Science','Reliability','TT_Heliopause'})
Results.Cost = double(Results.Cost);
Results.Science = double(Results.Science);
Results.Reliability = double(Results.Reliability);

%Add Data Tips
s = scatter(Results.Cost,Results.Science);
row = dataTipTextRow('Cost',Results.Cost);
s.DataTipTemplate.DataTipRows(1) = row;
row = dataTipTextRow('Science',Results.Science);
s.DataTipTemplate.DataTipRows(2) = row;
row = dataTipTextRow('Communications',Results.Communications);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Telemetry',Results.Telemetry);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Propulsion',Results.Propulsion);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Power',Results.Power);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Instruments',Results.Instruments);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Trajectory',Results.Trajectory);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Launch Vehicle',Results.Launch_Vehicle);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Kick Stages',Results.Kick_Stages);
s.DataTipTemplate.DataTipRows(end+1) = row;