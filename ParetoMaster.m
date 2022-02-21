%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Script Name: ParetoMaster
%Description: Calculates and Plots Pareto for Analysis
%Author: Jeremy Casella and Brendan Jones
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all
tic

%Define Possible Matrix Options
ComNet = ["DSN"]; %Communication Network Options
Telem = ["Ka" "X" "S"];     %Telemetry Band
Prop = ["OMS" "Solar Sail" "BHT-200" "BHT-600"];   %Propulsion Options
Power = ["RTG Nuclear"];  %Power Source Options
Instr = ["Minimum" "Mid Level" "High Level"];    %Instrumentation Options
Traj = ["JupSat" "JupSatO" "Log Spiral" "Solar Grav" "MarsJup"]; %Trajectory Options (O indicates impulse manuever during GA)
LaunchV = ["SLS Block 2", "Falcon Heavy", "Starship", "New Glenn", "Vulcan 6S"];    %Launch Vehicle Options
Kick = ["Castor 30XL" "Star 48BV", "Centaur V", "Nuclear", "Hybrid", "Centaur V & Star 48BV", ...
        "Centaur V & Nuclear", "Centaur V & Hybrid", "Star 48BV & Hybrid", "Star48 BV & Nuclear", ...
        "Hybrid & Nuclear", "Castor 30XL & Star 48BV", "Castor 30XL & Nuclear", ...
        "Castor 30XL & Hybrid", "No Kick Stage"];   %Kick Stages Options
NumKick = [0 1 2];

%Create Results Table
ResultsRaw = [];
Results10Raw = [];
PointColor = [];
PointColor10 = [];

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

            if i3 == "OMS"
                TrajAllow = ["JupSatO"];
            elseif i3 == "Solar Sail"
                TrajAllow = ["Log Spiral" "Solar Grav"];
            else
                TrajAllow = ["JupSat" "MarsJup"];
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
                            for i8 = NumKick
                                if i8 == 0;
                                    KickAllow = ["No Kick Stage"];
                                elseif i8 == 1;
                                    KickAllow = ["Star 48BV","Centaur V","Nuclear","Hybrid", "Castor 30XL"];
                                elseif i8 == 2;
                                    KickAllow = ["Centaur V & Star 48BV","Centaur V & Nuclear","Centaur V & Hybrid","Star 48BV & Hybrid","Star 48BV & Nuclear","Hybrid & Nuclear", "Castor 30XL & Star 48BV", "Castor 30XL & Nuclear", "Castor 30XL & Hybrid"];
                                end
                                for i9 = KickAllow
                                    candidateArchitecture.Communications = i1;
                                    candidateArchitecture.Telemetry = i2;
                                    candidateArchitecture.Propulsion = i3;
                                    candidateArchitecture.Power = i4;
                                    candidateArchitecture.Instruments = i5;
                                    candidateArchitecture.Trajectory = i6;
                                    candidateArchitecture.LaunchVehicle = i7;
                                    candidateArchitecture.num_Kick = i8;
                                    candidateArchitecture.Kick = i9;
                              
                                    %Call Mission Program
                                    [science, cost, reliability, ttHP, invalid] = MissionCalc(candidateArchitecture);

                                    if invalid == false
                                        %Create Table of Results etc
                                        ResultsRaw = [ResultsRaw; [i1 i2 i3 i4 i5 i6 i7 i8 i9 cost science reliability ttHP]];
                                        
                                        if ttHP <= 11;
                                            if ttHP <= 10;
                                                PointColor = [PointColor;0 1 0];
                                                PointColor10 = [PointColor10;0 1 0];
                                            else
                                                PointColor = [PointColor;0 0 1];
                                                PointColor10 = [PointColor10;0 0 1];
                                            end
                                            Results10Raw = [Results10Raw; [i1 i2 i3 i4 i5 i6 i7 i8 i9 cost science reliability ttHP]];
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
    end
end

%Parse Table
Results = array2table(ResultsRaw,'VariableNames', {'Communications','Telemetry','Propulsion','Power','Instruments','Trajectory','Launch_Vehicle','Number_Kick','Kick_Stages','Cost','Science','Reliability','TT_Heliopause'})
Results10= array2table(Results10Raw,'VariableNames', {'Communications','Telemetry','Propulsion','Power','Instruments','Trajectory','Launch_Vehicle','Number_Kick','Kick_Stages','Cost','Science','Reliability','TT_Heliopause'})

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
row = dataTipTextRow('Number of Kick Stages',Results.Number_Kick);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Kick Stages',Results.Kick_Stages);
s.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Time to Heliopause',Results.TT_Heliopause);
s.DataTipTemplate.DataTipRows(end+1) = row;

figure(2)
s2 = scatter(Results10.Cost,Results10.Science,[],PointColor10);
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
row = dataTipTextRow('Number of Kick Stages',Results10.Number_Kick);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Kick Stages',Results10.Kick_Stages);
s2.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Time to Heliopause',Results10.TT_Heliopause);
s2.DataTipTemplate.DataTipRows(end+1) = row;

toc
