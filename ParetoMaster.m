clc
clear
close all

%Define Possible Matrix Options
ComNet = [1:4]; %Communication Network Options
Prop = [1:4];   %Propulsion Options
Power = [1:4];  %Power Source Options
Instr = [1:3];    %Instrumentation Options
Traj = [1:5]; %Orbital Maneuver Options
Craft = [1:3];    %Number of Spacecraft
LaunchV = [1:4];    %Launch Vehicle
Kick = [1:6];   %Kick Stages

%Create Permutations of Missions
for i1 = ComNet
    for i2 = Prop
        for i3 = Power
            for i4 = Instr
                for i5 = Traj
                    for i6 = Craft
                        for i7 = LaunchV
                            for i8 = Kick
                                %Run Mission Calculations
                                Mission = [i1 i2 i3 i4 i5 i6 i7 i8]



                            end
                        end
                    end
                end
            end
        end
    end
end
