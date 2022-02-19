function [final_v, added_V, m_prop, m_inert] = generateC3( candidateArchitecture, m_pay )
    % Inputs: Launch Vehicle, Kick Stage Propulsion, C3 values (0,10,20,30,40,50,60,70,80,90,100, 110, 120)
    % Outputs: Delta V, Delta V caused by Kick Stage, Mass Payload, Structural Mass, Mass Propellant

    %% Setting Constants and Assumed Values (values to iterate over)
  
    array_LV = ["SLS", "Falcon Heavy", "Starship", "New Glenn", "Atlas V", "Vulcan 6S","Delta IV Heavy"]; % Array of Launch Vehicles
    kick_Stage = ["Centaur III", "Centaur V", "Star 48"];
    num_Kick = [0, 1, 2];
    g_E = 9.81; % (m/s^2)
    v_esc_E = 11200; % Escape velocity of Earth from LEO m/s
    
    %% Switch statement to determine assumed ISP (Impulse), Lambda (Payload 
    % Fraction), Inert Mass Fraction for kick stage

    switch candidateArchitecture.Kick 
        case "Star 48BV" % Solid Rocket 
            isp = 286;
            lambda = 0.939;
            m_kick1 = 2137 + m_pay;
        case "Centaur V" %Liquid
            isp = 451; % LH2/LOX
            lambda = 0.91; % Centaur Kick Stage
            m_kick1 = 22825 + m_pay;
        case "Nuclear" % LOOK AT BMX TECHNOLOGIES
            isp = 875; 
            lambda = 0.74; 
            m_kick = ;
        case "Hybrid" % LOOK AT SIERRA NEVADA
            isp = 325;
            lambda = 0.875; 
            m_kick = ;
        otherwise % No kick stage
            m_kick1 = m_pay;
            
    end

    %% Adding the combination of the mass of kick if kick stage = 2
    if( candidateArchitecture.num_Kick == 2 )
        
    end 

    %% Switch statement to determine C3 (km^2/s^2) at given payload mass
    % Uses equations from curvefit of C3 vs mass
    switch candidateArchitecture.LaunchVehicle
        case "SLS Block 1"
            C3 = -1.36254651049771e-11 * (m_kick1)^3 + ...
                8.34210950132914e-07 * (m_kick1)^2 + -0.0189976032356646 ...
                * m_kick1 + 172.041984919931;
        case "SLS Block 1B"
            C3 = -1.15085276593111e-12 * (m_kick1)^3 + ...
                1.18020100654521e-07 * (m_kick1)^2 + ...
                -0.00587448959766228 * m_kick1 + 119.768784427882;
        case "SLS Block 2"
            C3 = -1.10638439713243e-12 * (m_kick1)^3 + ...
                1.21222227649818e-07 * (m_kick1)^2 + ...
                -0.00602174622627308 * m_kick1 + 124.597075687923;
        case "Falcon Heavy Recoverable"
            C3 = -6.19433969053741e-11 * (m_kick1)^3 + ...
                1.348688172148435e-06 * (m_kick1)^2 + -0.0160 * m_kick1 ...
                + 64.84;
%         case "Falcon Heavy Expendable"
%             C3 = -2.202623249080307e-11 * (m_kick)^3 + ...
%                 8.680612077815912e-07 * (m_kick)^2 + -0.0155 * m_kick ...
%                 + 110.4074;
        case "Starship" 
            C3 = curvefit( m_kick1 );
        case "New Glenn"
            C3 = -4.42248334552639e-11 * (m_kick1)^3 + ...
                4.98373417329502e-07 * (m_kick1)^2 + -0.0055 * m_kick1 ...
                + 30.7952;
        case "Vulcan 6S"
            C3 = -6.89376184059982e-11 * (m_kick1)^3 + ...
                1.82960892594491e-06 * (m_kick1)^2 + -0.0225 * m_kick1 ...
                + 116.117;
        otherwise 
            
    end

    %% Calculations     
    if(candidateArchitecture.num_Kick == 1)        
        % Calculation mass propellant, inert mass, and Mass Ratio
        m_prop = (m_kick1 - m_pay) * lambda;
        m_inert = (m_kick1 - m_pay - m_prop); % Structural mass of the kick stage (Mass minus final payload and propellant)
        MR = (m_pay + m_prop + m_inert) / (m_pay + m_inert); % Mass Ratio

        % Calculation of Velocity Infinite with rocket equation (km/s)
        added_V = g_E * isp * log(MR); 
    elseif(candidateArchitecture.num_Kick == 2)
        %Stage 1:
        m_prop1 = (m_kick1 - m_pay - m_kick2) * lambda1;
        m_inert1 = (m_kick1 - m_pay - m_kick2 - m_prop1); 
        MR = ((m_pay + m_kick2) + m_prop1 + m_inert1) / (m_pay + m_inert1); 

        added_V = g_E * isp * log(MR); 
        
        %Stage 2:
        m_prop2 = (m_kick2 - m_pay) * lambda1;
        m_inert2 = (m_kick2 - m_pay - m_prop2); 
        MR = (m_pay + m_prop2 + m_inert2) / (m_pay + m_inert2); 

        added_V = added_V + g_E * isp * log(MR);
    else %num_kick = 0
        added_V = 0;
    end
    
    final_v = (added_V + sqrt(C3) + v_esc_E)/1000;

    if candidateArchitecture.Trajectory == "JupNepO" || candidateArchitecture.Trajectory == "JupSatO" 
        final_v = final_v - 700/1000;
    end
end
