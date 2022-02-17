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
        case "Star 48" % Solid Rocket 
            isp = 285;
            lambda = 0.92; % APCP Titan SRMU, Star 48 BV
            m_kick = ;
        case "Centaur V" %Liquid
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

    %% Switch statement to determine C3 (km^2/s^2) at given payload mass
    % Uses equations from curvefit of C3 vs mass
    switch candidateArchitecture.LaunchVehicle
        case "SLS"
            %m_kick = 44300; % SLS Block 2 Assumption at C3 = 0;
            C3 = -1.36254651049771e-11 * (m_kick)^3 + ...
                8.34210950132914e-07 * (m_kick)^2 + -0.0189976032356646 ...
                * m_kick + 172.041984919931;
        case "Falcon Heavy Recoverable"
            %m_kick = 9979.03; % 11 tons to LEO
            C3 = -6.19433969053741e-11 * (m_kick)^3 + ...
                1.348688172148435e-06 * (m_kick)^2 + -0.0160 * m_kick ...
                + 64.84;
        case "Falcon Heavy Expendable"
            C3 = -2.202623249080307e-11 * (m_kick)^3 + ...
                8.680612077815912e-07 * (m_kick)^2 + -0.0155 * m_kick ...
                + 110.4074;
        case "Starship" % NEED M0ASS OF KICK
            %m_kick = 50000; %A GUESS VALUE
            C3 = curvefit( m_kick );
        case "New Glenn"
            %m_kick = 7100;
            C3 = -4.42248334552639e-11 * (m_kick)^3 + ...
                4.98373417329502e-07 * (m_kick)^2 + -0.0055 * m_kick ...
                + 30.7952;
        case "Vulcan 6S"
            %m_kick = 10800;
            C3 = -6.89376184059982e-11 * (m_kick)^3 + ...
                1.82960892594491e-06 * (m_kick)^2 + -0.0225 * m_kick ...
                + 116.117;
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
