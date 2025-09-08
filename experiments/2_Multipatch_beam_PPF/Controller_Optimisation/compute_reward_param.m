%% Estimated time: 4:05:25 HH:MM:SS
clc
clear all
close all

warning('off','all')

localtime = datestr(now, 'yyyy_mm_dd_HH_MM_SS_FFF');

nNN=25%9%25%12; % 20??

% Diverge au bout de 70 episodes

rng('shuffle')
%rng(0)
%rng('default')


% % create the video writer with 1 fps
% writerObj = VideoWriter('myVideorw.avi');
% % set the seconds per image
% writerObj.FrameRate = 10;
% % open the video writer
% open(writerObj);

tic

numObs = 3;
ObsInfo=rlNumericSpec([numObs 1], ...
    'LowerLimit',-10 ,...
    'UpperLimit',10);
ObsInfo.Name='observation';
ObsInfo.Description='rms(acc1), rms(acc2) rms(acc3)';
DltInputDimension= prod(ObsInfo.Dimension); 
    
numAct = 9;
ActInfo = rlNumericSpec([numAct 1], ...
    'LowerLimit',[ -10; -10; -10; -10; -10; -10; -10; -10; -10],...
    'UpperLimit',[ 10; 10; 10; 10; 10; 10; 10; 10; 10]) %-10 +0.1


%Import su système Mimo: 3 input 3 output 
load('input_data_sys_cluster.mat')

%Définition du système discret
sys_mimo=sys_tf;
Ts=1/Fs;

%Définition des input output
sys_mimo.InputName = {'Pa1','Pa2','Pa3'};
sys_mimo.OutputName = {'Ps1','Ps2','Ps3'};

V_lp = lowpass(V,1000,10000);
time=[0:1:length(V(1,:))-1]*1/Fs;

env=model_exp_environement_multi_PPF(ObsInfo,ActInfo,Ts, time(1:end/1), V_lp(:,1:end/1), sys_mimo,'rwd_freq',[1 1 1]);

rng(0)
validateEnvironment(env)
reset(env)
env.norm=1


%%

K_opt_pre=-4e5
Xi_opt_pre=0.23
Ome_opt_pre=2.3876e3
Action_opt_pre_scaled=[ (log10(-K_opt_pre)/10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre/(1000*2*pi)-1/2)*2*10];
[~,Rwd_real_pr,~] = step(env,[Action_opt_pre_scaled; Action_opt_pre_scaled; Action_opt_pre_scaled]);

Action_test_k=[-10:1:2 2.2:0.2:7.8 8:1:10];
Action_test_xi=[-10:1:10];
Action_test_ome=[-10:1:10];

length(Action_test_ome) * length(Action_test_xi) * length(Action_test_k)

for i=1:length(Action_test_ome)
    for j=1:length(Action_test_xi)
        for k=1:length(Action_test_k)
            [~,Rwd(i,j,k),~] = step(env,[Action_test_k(k)*ones(1,3); Action_test_xi(j)*ones(1,3); Action_test_ome(i)*ones(1,3)]);

        end 
    end 
end

% 

filename = sprintf('Data/Reward/Reward_param_GM_%s.mat',localtime)
save(filename)