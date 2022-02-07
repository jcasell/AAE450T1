function [final_v, m_pay] = generateC3( candidateArchitecture, m_pay)
    % Inputs: Launch Vehicle, Kick Stage Propulsion
    % Outputs: Delta V, Mass Payload, Structural Mass, Mass Propellant

    %% Setting Constants and Assumed Values (values to iterate over)
    
    array_LV = ["SLS", "Falcon Heavy", "Starship", "New Glenn", "Atlas", "Delta"]; % Array of Launch Vehicles
    array_kick = ["Solid", "Liquid", "Nuclear", "Electric", "Hybrid", "None"]; % Array of Kick Stages
    g_E = 9.81; % (m/s^2)
    v_esc_E = 11200; % Escape velocity of Earth from LEO m/s
    
    % Switch statement to determine max payload (kg), (TOTAL MASS FOR KICK STAGE), at C3 = 0
    switch candidateArchitecture.LaunchVehicle
        case "SLS"
            m_kick = 44300; % SLS Block 2 Assumption
        case "Falcon Heavy" % Assuming Falcon Heavy Recoverable, could do Exendable
            m_kick = 6690;
        case "Starship" % NEED MASS OF KICK
            m_kick = 50000; %A GUESS VALUE
        case "New Glenn"
            m_kick = 7100;
        case "Atlas"
            m_kick = 0;
        case "Delta"
            m_kick = 0;
        otherwise 
            m_kick = m_pay;
    end

    % Switch statement to determine assumed ISP (Impulse), Lambda (Payload 
    % Fraction), Inert Mass Fraction for kick stage

    switch candidateArchitecture.Kick 
        case "Solid"
            isp = 285;
            lambda = 0.92; % APCP Titan SRMU 
        case "Liquid" %currently biprop
            %check monoprop
            isp = 450; % LH2/LOX
            lambda = 0.90; % Centaur Kick Stage
        case "Nuclear" % Nuclear Thermal Engine
            isp = 900; 
            lambda = 0.74; % US SNRE mass fraction, Dont have values for general nuclear
        case "Hybrid"
            isp = 325;
            lambda = 0.875; % Heister book
        otherwise % No kick stage
            isp = 0;
            lambda = 0;
    end

    %% Calculations 

    % Calculation mass propellant, inert mass, and Mass Ratio
    m_prop = (m_kick - m_pay) * lambda;
    m_inert = (m_kick - m_pay - m_prop); % Structural mass of the kick stage (Mass minus final payload and propellant)
    MR = (m_pay+m_prop+m_inert) / (m_pay+m_inert); % Mass Ratio

    % Calculation of Velocity Infinite with rocket equation (km/s)

    % add in how no kick stage would add in extra c3
    v_inf = g_E * isp * log(MR); 
    final_v = (v_inf + v_esc_E)/1000;
    if lambda == 0
        final_v = v_esc_E/1000;
    end

    if candidateArchitecture.Traj == "JupNep_O" || candidateArchitecture.Traj == "JupSat_O" 
        final_v = final_v - 700;
    end
end
