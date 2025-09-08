clc
clear all
close all

warning('off','all')

% To get a pseudo random 
rng('shuffle')
seed0=rng
seed1=rand(1)*100000
rng(seed1,'twister')
seed_init=rng
rand(1)

% To get always the same training
load('Data\Training\DRL_TRPO\raw\tested_seeds.mat')
rng(tested_seeds(17),'twister')

localtime = datestr(now, 'yyyy_mm_dd_HH_MM_SS_FFF');

tic

%% Agent Definition
nNN=25

% Critic
numObs = 3;
ObsInfo=rlNumericSpec([numObs 1], ...
    'LowerLimit',-10 ,...
    'UpperLimit',10);
ObsInfo.Name='observation';
ObsInfo.Description='rms(acc1), rms(acc2) rms(acc3)';
DltInputDimension= prod(ObsInfo.Dimension); 
    
NumHiddenUnitC=nNN;   
criticnet_default=[featureInputLayer(DltInputDimension,'Name', 'input_1'), ...
                        reluLayer('Name','relu_body0'),... 
                        fullyConnectedLayer(NumHiddenUnitC, 'Name', 'fc_1','WeightsInitializer','he','BiasInitializer','zeros'), ...
                        reluLayer('Name','relu_body1'),...                 
                        fullyConnectedLayer(NumHiddenUnitC, 'Name', 'fc_2','WeightsInitializer','he','BiasInitializer','zeros'), ...
                        reluLayer('Name','relu_body2'),...                 
                        fullyConnectedLayer(NumHiddenUnitC, 'Name', 'fc_3','WeightsInitializer','he','BiasInitializer','zeros'), ...
                        reluLayer('Name','relu_body3'),...                 
                        fullyConnectedLayer(1, 'Name', 'output','WeightsInitializer','he','BiasInitializer','zeros')]; %
                        
criticNetdefault=layerGraph(criticnet_default);
criticNet=criticNetdefault;
    
Critic = rlValueFunction(criticNet,ObsInfo);

% Actor
numAct = 9;
ActInfo = rlNumericSpec([numAct 1], ...
    'LowerLimit',[ -10; -10; -10; -10; -10; -10; -10; -10; -10],...
    'UpperLimit',[ 10; 10; 10; 10; 10; 10; 10; 10; 10]) %-10 +0.1
    
NumHiddenUnitA = nNN;
    
inputGraph=[featureInputLayer(DltInputDimension, 'Name', 'input_1'),...
                    fullyConnectedLayer(NumHiddenUnitA, 'Name', 'fc_1','WeightsInitializer','he','BiasInitializer','zeros'),...
                    reluLayer('Name','relu_body1'),...                 
                    fullyConnectedLayer(NumHiddenUnitC, 'Name', 'fc_2','WeightsInitializer','he','BiasInitializer','zeros'), ...
                    reluLayer('Name','relu_body2'),...                 
                    fullyConnectedLayer(NumHiddenUnitC, 'Name', 'fc_3','WeightsInitializer','he','BiasInitializer','zeros'), ...
                    reluLayer('Name','body_output')]; %
                                      
        
meanPath = fullyConnectedLayer(numAct, 'Name', 'fc_mean','WeightsInitializer','he','BiasInitializer','zeros');
    
[Scale, Bias] = getTanhScaleBias(ActInfo);
    Scale = Scale{:};
    Bias  = Bias{:};
    tanhScaleLayer = [
                tanhLayer('Name','tanh'),...
                scalingLayer('Name','scale','Scale',Scale,'Bias',Bias)]; %(X*Scale+bias)
        
meanPath = [
                meanPath,...
                tanhScaleLayer];
stdPath = [
            fullyConnectedLayer(numAct, 'Name', 'fc_std','WeightsInitializer','he','BiasInitializer','zeros');
            softplusLayer('Name', 'std');
            ];
    
    
actornet_default = layerGraph(inputGraph);
actornet_default = addLayers(actornet_default, meanPath);
actornet_default = addLayers(actornet_default, stdPath);
actornet_default = connectLayers(actornet_default,'body_output','fc_mean');
actornet_default = connectLayers(actornet_default,'body_output','fc_std');
actorNet=actornet_default;
    
Actor = rlContinuousGaussianActor(actorNet, ObsInfo, ActInfo, ...
            'ActionMeanOutputNames','scale',...
            'ActionStandardDeviationOutputNames','std',...
            'ObservationInputNames','input_1');
    
% Agent initialization
Agent_0 = rlTRPOAgent(Actor, Critic)

actor0 = getActor(Agent_0);
critic0= getCritic(Agent_0);

Agent_TRPO=Agent_0;

%% Environment 

% Import su système Mimo: 3 input 3 output 
load('../Model_Identification/Data/processed/sys_id.mat')
load('../Model_Identification/Data/processed/data_extracted_from_measurement_for_id.mat','Fs','V')

%Définition du système discret
sys_mimo=sys_tf;
Ts=1/Fs;

%Définition des input output
sys_mimo.InputName = {'Pa1','Pa2','Pa3'};
sys_mimo.OutputName = {'Ps1','Ps2','Ps3'};

V_lp = lowpass(V,1000,10000);
time=[0:1:length(V(1,:))-1]*1/Fs;

env=model_exp_environement_multi_PPF(ObsInfo,ActInfo,Ts, time(1:end/100), V_lp(:,1:end/100), sys_mimo,'rwd_freq',[1 1 1]);
%env=model_exp_environement_multi_PPF_phase(ObsInfo,ActInfo,Ts, time(1:end/100), V_lp(:,1:end/100), sys_mimo,'rwd_freq',[1 1 1]);

%validateEnvironment(env)
reset(env)
env.norm=0

%% Reward 

% Control off
K_opt_pre=0
Xi_opt_pre=0.23
Ome_opt_pre=2.3876e3
Action_opt_pre_scaled=[ (log10(-K_opt_pre)/10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre/(1000*2*pi)-1/2)*2*10];
[~,Rwd_real_0,~] = step(env,[Action_opt_pre_scaled; Action_opt_pre_scaled; Action_opt_pre_scaled]);


actorNet0 = getModel(actor0); 
criticNet0 = getModel(critic0);

test=dlarray(env.getInitialObservation,'C');
   
output=predict(actorNet0,test);
   
R=predict(criticNet0,test);

action=extractdata(output)
[~,Rwd_real0,~] = step(env,action);

% Control on target 

K_opt_pre=-5.6e5
Xi_opt_pre=0.23
Ome_opt_pre=2.3876e3
Action_opt_pre_scaled=[ (log10(-K_opt_pre)/10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre/(1000*2*pi)-1/2)*2*10];
[~,Rwd_real_pr,~] = step(env,[Action_opt_pre_scaled; Action_opt_pre_scaled; Action_opt_pre_scaled]);

%% Training

max_episode=50; % = 5000 
end_training=30

trainOpts = rlTrainingOptions(...
            'MaxEpisodes',max_episode,...
            'MaxStepsPerEpisode',10,...
            'Plots','training-progress',...
            'StopTrainingCriteria','AverageReward',...
            'StopTrainingValue',end_training,...
            'ScoreAveragingWindowLength',10,...
            'SaveAgentCriteria',"AverageReward", ...
            'SaveAgentValue',1000);%,...
            %'Plots',"none");

       
trainingStats_TRPO = train(Agent_TRPO,env,trainOpts);

%%
env

actor = getActor(Agent_TRPO);
critic= getCritic(Agent_TRPO);
% 

filename = sprintf('Data/Training_Agent_TRPO_3x25_5000_freq_init_seed%s.mat',localtime)
%save(filename)

%% Plot bode response
bopts= bodeoptions;
bopts.FreqUnits='Hz';
bopts.FreqScale='linear';
bopts.PhaseWrapping='on';
bopts.XLim={[0,1500]};
bopts.YLim={[-50,20]};
% 
figure
bode(env.Sys_mimo,bopts)
hold on
bode(env.sys_fb,bopts)
