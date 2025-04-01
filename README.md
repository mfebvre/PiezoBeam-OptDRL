# PiezoBeam-OptDRL

 PiezoBeam-OptDRL is an open-source MATLAB suite of live scripts designed to introduce Deep Reinforcement Learning (DRL) as an optimization strategy for smart structure control.
 The repository provides a 1D finite element model of a beam with piezoelectric transducers, enabling control through active and shunt strategies with the objective of vibration damping. This framework allows direct comparisons between DRL-based optimization and analytical methods from the literature.

Features
Main Live Script

    Smart_cantilever_beam_1D_FEM_livescript.mlx – Creates a 1D finite element model of a cantilever beam with one or two piezoelectric transducers.

Core Functions

    create_elementary_matrices.m – Generates elementary mass, stiffness, and piezoelectric coupling matrices.

    create_FEM_beam.m – Assembles the elementary matrices to obtain the finite element model with the appropriate boundary conditions.

    create_state_space.m – Converts the finite element model into a state-space representation with matrices A, B, C, and D.

    save_fig_pdf.m – Save matlab figures to pdf format


Contribution

Contributions are welcome! Feel free to open issues and submit pull requests.
License

This project is licensed under the GPL License.

Authors

Febvre Maryne

Reference

This code was developed as part of a PhD thesis on Mechanical engineering at INSA Lyon. The methodology, implementation, and results are detailed in:

Febvre Maryne, "Artificial intelligence to optimize distributed vibration control: Application to transducer networks in smart structures" Insa Lyon, 2025.

If you use this repository in your research or projects, please consider citing the thesis.

Acknowledgment 

This work was supported by the LABEX CeLyA (ANR-10-LABX-0060) of Université de Lyon, within the program “Investissements d’Avenir” operated by the French National Research Agency (ANR).