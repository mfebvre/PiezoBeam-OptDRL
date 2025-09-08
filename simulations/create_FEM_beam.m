function [Mcl, Kcl, Ccl, Nb_ddl, Kme_cl, Kem_cl, Kee_cl] = create_FEM_beam(data_length, Nb_element, M_elem,K_elem,M_eq, K_eq, Kme_e, Kem_e, Kee, dL_beam)
    % Function to compute the finite element model of a cantilever beam with a piezoelectric patch.
    % 
    % Inputs:
    % - data_length: Vector containing beam and piezo dimensions [L_beam, l_beam, h_beam, L_piezo, l_piezo, h_piezo, L_pos]
    % - Nb_element: Number of beam elements
    % - M_elem: Elementary mass matrix considering beam-only
    % - K_elem: Elementary stiffness matrix considering beam-only
    % - M_eq: Elementary mass matrix considering piezo-beam
    % - K_eq: Elementary stiffness matrix considering piezo-beam
    % - Kme_e: Elementary piezoelectric coupling Matrix
    % - Kem_e: Elementary piezoelectric coupling Matrix (Kme_e')
    % - Kee: Piezoelectric capacity
    % - dL_beam: Element length for beam elements
      
    % Extract piezoelectric material dimensions and properties
    L_piezo = data_length(4);
    L_pos = data_length(7);

    
    % Determine piezoelectric element range
    begin_piezo = round(L_pos / dL_beam);
    Nb_piezo = round(L_piezo / dL_beam);
    with_piezo = begin_piezo:Nb_piezo;

    % Initialize number of nodes and degrees of freedom
    Nb_noeud = Nb_element + 1;
    Nb_ddl = Nb_noeud * 2;

    % Initialize matrices
    M = zeros(Nb_ddl);
    K = zeros(Nb_ddl);
    Kme = zeros(Nb_ddl, 1);
    Kem = zeros(1, Nb_ddl);

    % Assemble the global stiffness and mass matrices
    for i = 1:Nb_element
        if min(abs(with_piezo - i)) == 0 % Piezoelectric element at position i
            % Add piezoelectric contributions to the mass, stiffness, and coupling matrices
            M((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) = M((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) + M_eq;
            K((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) = K((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) + K_eq;
            Kme((2*i-1):(2*i-1+3), 1) = Kme((2*i-1):(2*i-1+3), 1) + Kme_e;
            Kem(1, (2*i-1):(2*i-1+3)) = Kem(1, (2*i-1):(2*i-1+3)) + Kem_e;
        else
            % Standard beam element contribution
            M((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) = M((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) + M_elem;
            K((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) = K((2*i-1):(2*i-1+3), (2*i-1):(2*i-1+3)) + K_elem;
        end
    end

    % Apply boundary conditions by removing the rows and columns of blocked degrees of freedom
    Kcl = K(3:end, 3:end);
    Mcl = M(3:end, 3:end);
    Ccl = 0.0000001 * Kcl; % Damping matrix (a small value for simulation)
    Kme_cl = Kme(3:end, 1);
    Kem_cl = Kem(1, 3:end);
    Kee_cl = Kee;
end
