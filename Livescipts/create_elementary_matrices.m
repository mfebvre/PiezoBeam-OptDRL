function [M_b_elem,K_b_elem,M_pb_elem, K_pb_elem, Kme_elem, Kem_elem, Kee, dL_beam] = create_elementary_matrices(data_length, Nb_element, nb_patch, E_beam, rho_beam, E_piezo, rho_piezo, e33, epsilon_33)
    % Function to compute the elementary matrices of a cantilever beam with a piezoelectric patch.
    % 
    % Inputs:
    % - data_length: Vector containing beam and piezo dimensions [L_beam, l_beam, h_beam, L_piezo, l_piezo, h_piezo, L_pos]
    % - Nb_element: Number of beam elements
    % - nb_patch: Number of piezoelectric patches (1 or 2)
    % - E_beam: Young's modulus of the beam material
    % - rho_beam: Density of the beam material
    % - E_piezo: Young's modulus of the piezoelectric material
    % - rho_piezo: Density of the piezoelectric material
    % - e33: Piezoelectric coefficient
    % - epsilon_33: Dielectric permittivity
    
    % Extract beam dimensions from input
    L_beam = data_length(1);
    l_beam = data_length(2);
    h_beam = data_length(3);

    % Calculate the beam's moment of inertia and stiffness
    I_beam_Nb = l_beam * h_beam^3 / 12;
    S_beam = E_beam * I_beam_Nb;

    % Element length for beam elements
    dL_beam = L_beam / Nb_element;

    % Define the elementary stiffness and mass matrices for the beam
    K_b_elem = S_beam / dL_beam^3 * ...
        [12, 6*dL_beam, -12, 6*dL_beam;
         6*dL_beam, 4*dL_beam^2, -6*dL_beam, 2*dL_beam^2;
         -12, -6*dL_beam, 12, -6*dL_beam;
         6*dL_beam, 2*dL_beam^2, -6*dL_beam, 4*dL_beam^2];

    M_b_elem = rho_beam * h_beam * l_beam * dL_beam / 420 * ...
        [156, 22*dL_beam, 54, -13*dL_beam;
         22*dL_beam, 4*dL_beam^2, 13*dL_beam, -3*dL_beam^2;
         54, 13*dL_beam, 156, -22*dL_beam;
         -13*dL_beam, -3*dL_beam^2, -22*dL_beam, 4*dL_beam^2];

    % Extract piezoelectric material dimensions and properties
    L_piezo = data_length(4);
    l_piezo = data_length(5);
    h_piezo = data_length(6);
    L_pos = data_length(7);

    % Inertia and stiffness for the piezoelectric patch
    I_piezo_Np = l_piezo * h_piezo^3 / 12;
    I_piezo_Nb = I_piezo_Np + h_piezo * l_piezo * (h_piezo / 2 + h_beam / 2)^2;
    S_piezo = E_piezo * I_piezo_Nb;

    % Equivalent inertia and density when combining beam and piezoelectric elements
    I_bp_Nb = I_beam_Nb + I_piezo_Nb;
    rho_eq = (rho_beam * h_beam + rho_piezo * h_piezo) / (h_beam + h_piezo); % Mean density
    if nb_patch == 1
        S_bp_Nb = S_beam + S_piezo;
    elseif nb_patch == 2
        S_bp_Nb = S_beam + 2 * S_piezo;
    end

    % Modify the elementary stiffness and mass matrices including piezoelectric elements
    K_pb_elem = S_bp_Nb / S_beam * K_b_elem;
    M_pb_elem = rho_eq * (h_beam + h_piezo) / (rho_beam * h_beam) * M_b_elem;

    % Electric part: piezoelectric parameters
    Kme_elem = e33 * l_piezo * (h_piezo + h_beam) / 2 * [0; -1; 0; 1];
    Kem_elem = Kme_elem';
    Kee = l_piezo * h_piezo * epsilon_33 / h_piezo;
end
