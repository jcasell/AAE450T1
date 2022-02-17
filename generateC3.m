function [final_v, v_inf,m_kick, m_prop, m_inert] = generateC3( candidateArchitecture, m_pay, kick_Stage, num_Kick )
    % Inputs: Launch Vehicle, Kick Stage Propulsion, C3 values (0,10,20,30,40,50,60,70,80,90,100, 110, 120)
    % Outputs: Delta V, Delta V caused by Kick Stage, Mass Payload, Structural Mass, Mass Propellant

    %% Setting Constants and Assumed Values (values to iterate over)
  
    array_LV = ["SLS", "Falcon Heavy", "Starship", "New Glenn", "Atlas V", "Vulcan 6S","Delta IV Heavy"]; % Array of Launch Vehicles
    array_kick = ["Solid", "Liquid", "Nuclear", "Hybrid", "None"]; % Array of Kick Stages
    kick_stage = ["Centaur III", "Centaur V", "Star 48"];
    g_E = 9.81; % (m/s^2)
    v_esc_E = 11200; % Escape velocity of Earth from LEO m/s
    
    %% Switch statement to determine assumed ISP (Impulse), Lambda (Payload 
    % Fraction), Inert Mass Fraction for kick stage

    switch candidateArchitecture.Kick 
        case "Solid" 
            isp = 285;
            lambda = 0.92; % APCP Titan SRMU, Star 48 BV
            m_kick = ;
        case "Liquid" %currently biprop
            %check monoprop
            isp = 450; % LH2/LOX
            lambda = 0.90; % Centaur Kick Stage
            m_kick = ;
        case "Nuclear" % sNuclear Thermal Engine
            isp = 875; 
            lambda = 0.74; % US SNRE mass fraction, Dont have values for general nuclear
            m_kick = ;
        case "Hybrid"
            isp = 325;
            lambda = 0.875; % Heister book
            m_kick = ;
        otherwise % No kick stage
            m_kick = m_pay;
            
    end

    %% Switch statement to determine max payload (kg), (TOTAL MASS FOR KICK STAGE), at C3 = 0
    switch candidateArchitecture.LaunchVehicle
        case "SLS"
            %m_kick = 44300; % SLS Block 2 Assumption at C3 = 0;
            C3 = curvefit( m_kick );
        case "Falcon Heavy"
            %m_kick = 9979.03; % 11 tons to LEO
            C3 = curvefit( m_kick );
        case "Falcon Heavy Expendable"
            C3 = curvefit( m_kick );
        case "Starship" % NEED MASS OF KICK
            %m_kick = 50000; %A GUESS VALUE
            C3 = curvefit( m_kick );
        case "New Glenn"
            %m_kick = 7100;
            C3 = curvefit( m_kick );
        case "Atlas V"
            %m_kick = 6750;
            C3 = curevfit( m_kick );
        case "Vulcan 6S"
            %m_kick = 10800;
            C3 = curvefit( m_kick );
        case "Delta IV Heavy"
            %m_kick = 10500;
            C3 = curevfit( m_kick );
        otherwise 
            
    end

    %% Calculations 
    v_inf = 0;
    
    if(num_Kick > 0)
        % Calculation mass propellant, inert mass, and Mass Ratio
        m_prop = (m_kick - m_pay) * lambda;
        m_inert = (m_kick - m_pay - m_prop); % Structural mass of the kick stage (Mass minus final payload and propellant)
        MR = (m_pay + m_prop + m_inert) / (m_pay + m_inert); % Mass Ratio

        % Calculation of Velocity Infinite with rocket equation (km/s)
        v_inf = g_E * isp * log(MR); 
    end
    
    final_v = (v_inf + sqrt(C3) + v_esc_E)/1000;
    if lambda == 0
        final_v = v_esc_E/1000;
    end

    if candidateArchitecture.Trajectory == "JupNepO" || candidateArchitecture.Trajectory == "JupSatO" 
        final_v = final_v - 700/1000;
    end
end
