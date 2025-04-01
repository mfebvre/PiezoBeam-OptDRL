function [Sys_nc, A, B, C, D, N] = create_state_space(M, G, K, Nb_ddl, Fu1, Fu2, Cd1, Cd2, Dd)
    %% State-Space Representation
    % This function computes the state-space matrices for the structural system, considering
    % the mass (M), damping (G), and stiffness (K) matrices, as well as external forces 
    % and outputs related to the system. It is based on a standard formulation of a 
    % mechanical system with displacement and velocity as states.

    % Define the number of degrees of freedom (states) excluding boundary conditions
    N = Nb_ddl - 2;

    %% State-Space Matrices
    % The state-space representation is given by:
    % x_dot = A * x + B * u
    % y = C * x + D * u

    % System matrices for the state-space model
    A = [zeros(N) eye(N); -inv(M) * K -inv(M) * G];  % State transition matrix (A)
    B = [zeros(N, 1) zeros(N, 1); -inv(M) * Fu1 inv(M) * Fu2];  % Input matrix (B)
    C = [Cd1' zeros(1, N); Cd2' zeros(N, N)];  % Output matrix (C)
    D = [Dd 0; zeros(N, 1) zeros(N, 1)];  % Feedthrough matrix (D)

    %% State Variable Names
    % This part sets the names for the states and outputs to be used in the system
    % description. It generates names based on the degrees of freedom and state variables.
    
    % Define output names (e.g., Charge 'q' and other outputs)
    name_output{1} = ['Charge' '_' 'q'];  % Charge for the system
    name{1} = ['w' '_' '0' num2str(1, '%d')];  % First state variable (displacement)
    
    % Generate names for the velocity (omega_i) and displacement (theta_i) for the first half
    for i = 1:N/2
        w_i = ['w' '_{' num2str(i, '%d') '}'];  % Displacement state (w)
        theta_i = ['\theta' '_{' num2str(i, '%d') '}'];  % angular displacement state (theta)
        
        name{2*i - 1} = w_i;  % Name for angular velocity state
        name{2*i} = theta_i;  % Name for displacement state
        name_output{2*i} = w_i;  % Output for displacement
        name_output{2*i + 1} = theta_i;  % Output for angular displacement
    end   

    % Generate names for the remaining velocity and displacement states in the second half
    for i = N/2 + 1:N
        w_i = ['\dotw' '_{' num2str(i - N/2, '%d') '}'];  % Velocity (dot w)
        theta_i = ['\dottheta' '_{' num2str(i - N/2, '%d') '}'];  % Angular Velocity (dot theta)
        
        name{2*i - 1} = w_i;  % Name for displacement state
        name{2*i} = theta_i;  % Name for angular displacement state
    end  

    %% Create State-Space System Object
    % Use the MATLAB ss (state-space) function to create the system object
    % with the state, input, and output names defined above.

    Sys_nc = ss(A, B, C, D, ...
        'StateName', name, ...  % Name for each state variable
        'InputName', {'Impedance sZ', 'Force F_u'}, ...  % Name for inputs (Impedance and Force)
        'OutputName', name_output);  % Name for outputs (charge and states)

end
