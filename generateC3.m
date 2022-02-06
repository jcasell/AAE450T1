function [c3, m_pay] = generateC3( candidateArchitecture )
    % Inputs: Launch Vehicle, Kick Stage Propulsion
    % Outputs: Delta V, Mass Payload, Structural Mass, Mass Propellant

    %% Setting Constants and Assumed Values (values to iterate over)
    
    array_LV = ["SLS", "Falcon Heavy", "Starship", "New Glenn"]; % Array of Launch Vehicles
    array_kick = ["Solid", "Liquid", "Nuclear", "Electric", "Hybrid", "None"]; % Array of Kick Stages
    g_E = 9.81; % (m/s^2)
    v_esc_E = 11200; % Escape velocity of Earth from LEO m/s
    
    % Switch statement to determine max payload (kg), (TOTAL MASS FOR KICK STAGE), at C3 = 0
    switch candidateArchitecture.LV 
        case "SLS"
            m_kick = 44300; % SLS Block 2 Assumption
        case "Falcon Heavy" % Assuming Falcon Heavy Recoverable, could do Exendable
            m_kick = 6690;
        case "Starship" % NEED MASS OF KICK
            m_kick = 0;
        case "New Glenn"
            m_kick = 7100;
        case "Atlas"
            m_kick = 0;
        case "Delta"
            m_kick = 0;
        otherwise 
            m_kick = 0;
    end

    hi

    % Switch statement to determine assumed ISP (Impulse), Lambda (Payload 
    % Fraction), Inert Mass Fraction for kick stage

    switch candidateArchitecture.kick 
        case "Solid"
            isp = 225;
            lambda = 0.875;
        case "Liquid"
            if type == "mono"
                isp = 400;
                lambda = 0.3; %Wrong?
            else % type is biprop
                isp = 380;
                lambda = 0.8;
            end 
        case "Nuclear" % Nuclear Thermal Engine
            isp = 900;
            lambda = 0.74; % US SNRE mass fraction, Dont have values for general nuclear
        case "Electric"
            isp = 2000;
            lambda = 0; %Ion or Arcjet?
        case "Hybrid"
            isp = 325;
            lambda = 0.875;
        otherwise % No kick stage
            isp = 0;
            lambda = 0;
    end

    %% Calculations 

    % these calculations are wrong, Lambda gets you the dry weight (inert mass)
    % Lambda = payload mass / full mass - payload mass; lambda (full - pay)
    % = pay; lambda * full = pay + lambda pay; lambda * full / (1+lambda) =
    % pay

    % LAMBDA IS PROPELLANT MASS RATIO NOT PAYLOAD RATIO

    m_prop = 
    m_pay = (m_kick * lambda) / (1 + lambda); % Mass of the payload
    f_inert = 1/lambda - 1;
    m_inert = m_kick * f_inert; % Structural mass of the kick stage (Mass minus final payload and propellant)
    m_prop = m_kick - m_inert - m_pay; % Mass of the propellant
    

    % Calculate Mass Ratio
    MR = (m_pay+m_prop+m_inert) / (m_pay+m_inert); % Mass Ratio
    MR = (lambda * m_pay + m_prop) / (lamba * m_pay + m_prop(1-lambda)); % Alternate Mass Ratio Eqn.

    % Calculation of Velocity Infinite with rocket equation
    v_inf = g_E * isp * ln(MR); 
    total_v_inf = v_inf + v_esc_E;
    
    c3 = total_v_inf^2; %???
end