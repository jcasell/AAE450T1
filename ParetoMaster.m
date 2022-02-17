%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Script Name: ParetoMaster
%Description: Calculates and Plots Pareto for Analysis
%Author: Jeremy Casella
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all

%Define Possible Matrix Options
ComNet = ["DSN" "IDSN" "NSN"]; %Communication Network Options
Telem = ["Ka" "X" "S"];     %Telemetry Band
Prop = ["Chemical" "Solar Sail" "BHT_100" "BHT_600"];   %Propulsion Options
Power = ["RTG Nuclear" "Solar Panel/Nuclear" "Solar Panel"];  %Power Source Options
Instr = ["Minimum" "Mid Level" "High Level"];    %Instrumentation Options
Traj = ["JupNep" "JupSat" "JupNepO" "JupSatO"]; %Trajectory Options (O indicates impulse manuever during GA)
LaunchV = ["SLS" "Falcon Heavy" "Vulcan 6S" "Starship"];    %Launch Vehicle Options
Kick = ["Solid" "Liquid" "Hybrid" "None"];   %Kick Stages Options

%Create Results Table
ResultsRaw = [];
Results10Raw = [];
PointColor = [];

%Create Permutations of Missions
for i1 = ComNet
    %Only Include Relevant Combination
    if i1 == "DSN"
        TelemAllow = ["Ka"];
    else
        TelemAllow = Telem;
    end

    for i2 = TelemAllow
        for i3 = Prop
            %Only Include Relevant Combination
            if or(i3 == "None",i3 == "Plasma")
                TrajAllow = ["JupNep","JupSat"];
            elseif i3 == "Solar Sail"
                TrajAllow = ["Solar Sail"];
            else
                TrajAllow = Traj;
            end
            for i4 = Power
                %Only Include Relevant Combination
                if i4 == "Solar Panel"
                    InstrAllow = ["Minimum"];
                else
                    InstrAllow = Instr;
                end
                for i5 = InstrAllow
                    for i6 = TrajAllow
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
                                
                                if ttHP <= 10;
                                    PointColor = [PointColor;0 1 0];
                                    Results10Raw = [Results10Raw; [i1 i2 i3 i4 i5 i6 i7 i8 cost science reliability ttHP]];
                                elseif ttHP <= 12
                                    PointColor = [PointColor;0 0 1];
                                else
                                    PointColor = [PointColor;1 0 0];
                                end
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
Results10= array2table(Results10Raw,'VariableNames', {'Communications','Telemetry','Propulsion','Power','Instruments','Trajectory','Launch_Vehicle','Kick_Stages','Cost','Science','Reliability','TT_Heliopause'})

Results.Cost = double(Results.Cost);
Results.Science = double(Results.Science);
Results.Reliability = double(Results.Reliability);
Results.TT_Heliopause = double(Results.TT_Heliopause);

Results10.Cost = double(Results10.Cost);
Results10.Science = double(Results10.Science);
Results10.Reliability = double(Results10.Reliability);
Results10.TT_Heliopause = double(Results10.TT_Heliopause);


%Add Data Tips
figure(1)
s = scatter(Results.Cost,Results.Science,[],PointColor);
xlabel('System Cost (F2022 Millions of Dollars)')
ylabel('Science Value')
title('Science Value vs Cost Pareto Frontier')

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
row = dataTipTextRow('Time to Heliopause',Results.TT_Heliopause);
s.DataTipTemplate.DataTipRows(end+1) = row;

figure(2)
s2 = scatter(Results10.Cost,Results10.Science);
xlabel('System Cost (F2022 Millions of Dollars)')
ylabel('Science Value')
title('Viable Results Science Value vs Cost Pareto Frontier')

row = dataTipTextRow('Cost',Results10.Cost);
s2.DataTipTemplate.DataTipRows(1) = row;
row = dataTipTextRow('Science',Results10.Science);
s2.DataTipTemplate.DataTipRows(2) = row;
row = dataTipTextRow('Communications',Results10.Communications);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Telemetry',Results10.Telemetry);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Propulsion',Results10.Propulsion);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Power',Results10.Power);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Instruments',Results10.Instruments);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Trajectory',Results10.Trajectory);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Launch Vehicle',Results10.Launch_Vehicle);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Kick Stages',Results10.Kick_Stages);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Time to Heliopause',Results10.TT_Heliopause);
s2.DataTipTemplate.DataTipRows(end+1) = row;
