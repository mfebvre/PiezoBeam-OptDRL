# PiezoBeam-OptDRL

## Overview

**PiezoBeam-OptDRL** is an open-source MATLAB suite of live scripts designed to introduce Deep  Reinforcement Learning (DRL) as an optimization strategy for smart structure control with piezoelectric transducers.  
It combines **finite element simulations** of a smart beam with **experimental studies** on multiple structures, supporting both analytical methods from the literature and modern optimization approaches such as Deep Reinforcement Learning (DRL).

---
## Repository structure

- **`simulations/`**  
    Contains MATLAB live scripts and functions for 1D finite element modeling of a cantilever beam with two colocated piezoelectric transducers.  
    Includes:
    
Features
Main Live Script
    - **`Smart_cantilever_beam_1D_FEM_livescript.mlx`** – Build the finite element model.
        
	- **`Smart_cantilever_beam_1D_opti_active_crtl_biblio_livescript.mlx`** – Active control with literature-based tuning.
        
    - **`Smart_cantilever_beam_1D_opti_shunt_biblio_livescript.mlx`** – Shunt control with literature-based optimization.
    - **`Smart_cantilever_beam_1D_active_crtl_tuning_Reinforcement_Learning_livescript.mlx`** – (Comming soon)
    - **`Smart_cantilever_beam_1D_shunt_tuning_Reinforcement_Learning_livescript.mlx`** – (Comming soon)

Core Functions

    create_elementary_matrices.m – Generates elementary mass, stiffness, and piezoelectric coupling matrices.

    create_FEM_beam.m – Assembles the elementary matrices to obtain the finite element model with the appropriate boundary conditions.

    create_state_space.m – Converts the finite element model into a state-space representation with matrices A, B, C, and D.

    save_fig_pdf.m – Save matlab figures to pdf format

        
- **`experiments/`**
	- **`1_Monopatch_beam_D_LL/** – Code and data used in publication [1] (Code avalable soon)
	- **`2_Multipatch_beam_PPF/`** – Code and data used in publication [2]
	  - **`Model_Identification/`** – Transfer function model identification from test-bench measurements.  
	  - **`Controller_Implementation/`** – Active control with a PPF controller: model vs. test-bench comparison.  
	  - **`Controller_Optimisation/`** – Active control with PPF controller tuning using DRL and the Simplex methods.  

 
Contribution

Contributions are welcome! Feel free to open issues and submit pull requests.
License

This project is licensed under the GPL License.

Authors

Febvre Maryne

Reference

This code was developed as part of a PhD thesis in Mechanical Engineering at INSA Lyon.  
The methodology, implementation, and results are presented in the following publications:

Article:
[1] Febvre Maryne, "Deep reinforcement learning for tuning active vibration control on a smart piezoelectric beam", _Journal of Intelligent Material Systems and Structures_. 2024;35(14):1149-1165. DOI: [10.1177/1045389X241260976](https://doi.org/10.1177/1045389X241260976)

[2] Febvre Maryne, "Deep Reinforcement Learning for Optimizing Control Law Parameters on a Smart Beam with Distributed Piezoelectric Transducers", 2025

Thesis:
Febvre Maryne, "Artificial intelligence to optimize distributed vibration control: Application to transducer networks in smart structures" Insa Lyon, 2025.

If you use this repository in your research or projects, please consider citing the thesis.

Acknowledgment 

This work was supported by the LABEX CeLyA (ANR-10-LABX-0060) of Université de Lyon, within the program “Investissements d’Avenir” operated by the French National Research Agency (ANR).