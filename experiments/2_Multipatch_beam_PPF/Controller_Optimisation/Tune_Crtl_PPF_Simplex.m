clc
clear all
close all

warning('off','all')

%Import su système Mimo: 3 input 3 output 
load('../Model_Identification/Data/processed/sys_id.mat')
load('../Model_Identification/Data/processed/data_extracted_from_measurement_for_id.mat','Fs','V')

%Définition du système discret
sys_mimo=sys_tf;
Ts=1/Fs;

%Définition des input output
sys_mimo.InputName = {'Pa1','Pa2','Pa3'};
sys_mimo.OutputName = {'Ps1','Ps2','Ps3'};

%Fin de la définition du système 
fprintf('MIMO done.');

numObs = 3;
ObsInfo=rlNumericSpec([numObs 1], ...
    'LowerLimit',-inf ,...
    'UpperLimit',inf);
ObsInfo.Name='observation';
ObsInfo.Description='rms(Ps1), rms(Ps2) rms(Ps3)';
DltInputDimension= prod(ObsInfo.Dimension); 
    
numAct = 9;
ActInfo = rlNumericSpec([numAct 1], ...
    'LowerLimit',[ -10; -10; -10; -10; -10; -10; -10; -10; -10],...
    'UpperLimit',[ 10; 10; 10; 10; 10; 10; 10; 10; 10]) %-10 +0.1

%ActInfo.Name='Tune';
%ActInfo.Description='Coeff, Lead, Lag';


V_lp = lowpass(V,1000,10000);
time=[0:1:length(V(1,:))-1]*1/Fs;

env=model_exp_environement_multi_PPF(ObsInfo,ActInfo,Ts, time(1:end/100), V_lp(:,1:end/100), sys_mimo,'rwd_freq',[1 1 1]);

rng(0)
validateEnvironment(env)
reset(env)
env.norm=0

K_opt_pre=-5.6e5
Xi_opt_pre=0.23
Ome_opt_pre=2.3876e3
Action_opt_pre_scaled=[ (log10(-K_opt_pre)/10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre/(1000*2*pi)-1/2)*2*10];
[~,Rwd_real_pr,~] = step(env,[Action_opt_pre_scaled; Action_opt_pre_scaled; Action_opt_pre_scaled]);


%% Define wrapper function to return only the second output
objective_function = @(params) -my_wrapper_function(env,params);

% Bounds for each parameter [lower_bound, upper_bound]
% lb = [-1,-1,-1]
% ub = [ 0, 0, 0] %0.0001-0.001
lbi = [ -10, -10, -10, -10, -10, -10, -10, -10, -10]
ubi = [ 10, 10, 10, 10, 10, 10, 10, 10, 10] %0.0001-0.001


%% Random to find a stable init point
Reward_test=-1
while Reward_test<0
    rng("shuffle")
    initial_guesses = lbi + rand(size(lbi)) .* (ubi - lbi);
    %initial_guesses(i,:) = [1e-5,1e-5,1e-5];
    
    [~,Reward_test,~,~]=step(env,[initial_guesses]);
end

Reward_test

%% Or get init point from DRL Init
load("Data\Training\DRL_TRPO\raw\Training_Agent_TRPO_3x25_5000_freq_init_seed2024_09_19_17_19_01_052.mat",'actor0')

actorNet0 = getModel(actor0); 
test=dlarray(env.getInitialObservation,'C');
output=predict(actorNet0,test);
action=extractdata(output)

%% Simplex Tuning
options = optimset('PlotFcns',@optimplotfval);
[optimal_params, max_value, exitflag, output] = fminsearch(objective_function, initial_guesses,options);

localtime = datestr(now, 'yyyy_mm_dd_HH_MM_SS_FFF');
filename = sprintf('Data_cluster/Data_fminsearch_multi_PPF_%s.mat',localtime)
%save(filename)
%%

%[optimal_params, max_value,exitflag,output] = fminsearch(objective_function, initial_guesses, options);
% Display results
disp('Optimal Parameters:');
disp(optimal_params);
disp('Maximum Value:');
disp(-max_value); % Since we're maximizing, negate the result
disp('Output');
disp(output); 

step(env,[optimal_params]);
env
env.K_value
env.Xi_value
env.Ome_value

bopts= bodeoptions;
bopts.FreqUnits='Hz';
bopts.FreqScale='linear';
bopts.PhaseWrapping='on';
bopts.XLim={[0,1500]};
%bopts.YLim={[-50,20]};

figure
bode(env.Sys_mimo,bopts)
hold on
bode(env.sys_fb,bopts)

