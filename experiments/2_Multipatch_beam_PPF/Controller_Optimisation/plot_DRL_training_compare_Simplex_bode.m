clc
clear all
close all
%% Plot training initial training

%DRL

path_DRL="Data\Training\DRL_TRPO\processed\"

load(string(path_DRL)+"extracted_data_240919_training_GM.mat",'trng','env','Rwd_real','file_name','Rwd_real_pr')

Index17=find(Rwd_real>15.5)
Index13_17=find((Rwd_real<15.5).*(Rwd_real>=13))
Index9_13=find((Rwd_real<13).*(Rwd_real>20*log10(3)))

for j=1:3

    if j==1
        Index=Index9_13;
    end
    if j==2
        Index=Index13_17;
    end
    if j==3
        Index=Index17([1:3 5 6]);%
    end

max_episode=5000
k=1.96;
N=length(file_name)
T = NaN(N,max_episode);
Reward = array2table(T);
AVGReward = array2table(T);
for i=1:N
    Reward(i,:)=array2table(trng{1,i}.trainingStats_TRPO.EpisodeReward(:)');
    AVGReward(i,:)=array2table(trng{1,i}.trainingStats_TRPO.EpisodeReward(:)');
end
%Moyenne
Reward=table2array(Reward);
AVGReward=table2array(AVGReward);
%Ep_rw_mean=mean(Reward(1:3+7:10,:),1,'omitnan');

Ep_rw_mean=mean(Reward(Index,:),1,'omitnan');%mean(Reward(Index,:),1,'omitnan');
%Ecart type 
%S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
S=std(Reward(Index,:),1,'omitnan');%std(Reward(Index,:),1,'omitnan');
Rwd_min=Ep_rw_mean-k*S/(sqrt(size(Index,2)-1));
Rwd_max=Ep_rw_mean+k*S/(sqrt(size(Index,2)-1));

fig=figure
%subplot(2,1,1)
hold on
fill([1 : max_episode, fliplr(1 : max_episode)], [Rwd_min, fliplr(Rwd_max)], [0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot([1: 20 :max_episode]  ,Ep_rw_mean(1: 20 :end)','Color',[0 0.4470 0.7410],'LineStyle','-')
%plot([1: max_episode]  ,Ep_rw_mean(1:end)','Color',[0 0.4470 0.7410])
xlabel('Episode Number')
ylabel('Episode Reward')

K_opt_pre=-4e5
Xi_opt_pre=0.23
Ome_opt_pre=2.3876e3
Action_opt_pre_scaled=[ (log10(-K_opt_pre)/10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre/(1000*2*pi)-1/2)*2*10];
[~,Rwd_real_pr,~] = step(env,[Action_opt_pre_scaled; Action_opt_pre_scaled; Action_opt_pre_scaled]);

plot([1 max_episode],[Rwd_real_pr Rwd_real_pr],'Color','k','LineStyle','-.')
hold on
K_opt_pre=[0 0 0]
Xi_opt_pre=[0.3663 0.1 0.2844]
Ome_opt_pre=[2.5788e3 4.4911e3 2.2619e3]
Action_opt_pre_scaled=[ (log10(-K_opt_pre)./10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre./(1000*2*pi)-1/2)*2*10];
[~,Rwd_0,~] = step(env,[Action_opt_pre_scaled]);
plot([1 max_episode],[Rwd_0 Rwd_0],'Color','k','LineStyle','--')
ylim([-1 22])
legend('Std Reward','Mean Reward','Reward hand-adjusted controler','Reward control off','Location','southeast')

    if j==1
        savefig('Figure\Training_Reward_var_913')
        save_fig_pdf('Figure\Training_Reward_var_913')
    end
    if j==2
        savefig('Figure\Training_Reward_var_13_17')
        save_fig_pdf('Figure\Training_Reward_var_13_17')
    end
    if j==3
        savefig('Figure\Training_Reward_var_17')
        save_fig_pdf('Figure\Training_Reward_var_17')
    end



end

% hold on Simplex 

path_Simplex="Data\Training\Simplex\processed\"

load(string(path_Simplex)+"extracted_data_240919_simplex_GM.mat")

%Case
Index17=find(Rwd_real>15.5)
Index13_17=find((Rwd_real<15.5).*(Rwd_real>=13.65))
Index9_13=find((Rwd_real<13.65).*(Rwd_real>20*log10(3)))
for j=1:3
 if j==1
        Index=Index9_13;
    end
    if j==2
        Index=Index13_17;
    end
    if j==3
        Index=Index17;%
    end

    if j==1 
        fig=openfig('Figure\Training_Reward_var_913')
    end
    if j==2 
        fig=openfig('Figure\Training_Reward_var_13_17')
    end
    if j==3 
        fig=openfig('Figure\Training_Reward_var_17')        
    end

Reward=Rwd_real;
max_episode=5000

k=1.96;
Ep_rw_mean=mean(Reward(Index),2,'omitnan');%mean(Reward(Index,:),1,'omitnan');
%Ecart type 
%S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
S=std(Reward(Index),1,'omitnan');%std(Reward(Index,:),1,'omitnan');
Rwd_min=Ep_rw_mean-k*S/(sqrt(size(Index,2)-1));
Rwd_max=Ep_rw_mean+k*S/(sqrt(size(Index,2)-1));

hold on   
fill([[1  max_episode], fliplr([1 max_episode])], [[Rwd_min Rwd_min], fliplr([Rwd_max Rwd_max])], [1 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot([1 max_episode]  , [Ep_rw_mean Ep_rw_mean],'Color',[1 0.4470 0.7410],'LineStyle','-')

legend('Std Reward DRL','Mean Reward DRL','Reward hand-adjusted controler','Reward control off','Std Reward Simplex','Mean Reward Simplex','Location','southeast')

    if j==1 
        savefig('Figure\Training_Reward_var_913')
        save_fig_pdf('Figure\Training_Reward_var_913')
    end
    if j==2 
        savefig('Figure\Training_Reward_var_13_17')
        save_fig_pdf('Figure\Training_Reward_var_13_17')
    end
    if j==3 
        savefig('Figure\Training_Reward_var_17')  
        save_fig_pdf('Figure\Training_Reward_var_17')  
    end
end 

%% Plot bode 

clc
clear all
close all
plot_phase=0

% DRL 

path_DRL="Data\Training\DRL_TRPO\processed\"
path_Simplex="Data\Training\Simplex\processed\"

 
load(string(path_DRL)+"extracted_data_240919_training_GM.mat",'Rwd_real','w','magg21','phaseg21','magg2','phaseg2','magg23','phaseg23','env')

Index17=find(Rwd_real>15.5)
Index13_17=find((Rwd_real<15.5).*(Rwd_real>=13))
Index9_13=find((Rwd_real<13).*(Rwd_real>20*log10(3)))

for j=1:3
    if j==1
        Index=Index9_13;
    end
    if j==2
        Index=Index13_17;
    end
    if j==3
        Index=Index17([1:3 5 6]);%
    end
magg{1}=magg21(Index,:);%to modif
phaseg{1}=phaseg21(Index,:);%to modif
magg{2}=magg2(Index,:);%to modif
phaseg{2}=phaseg2(Index,:);%to modif
magg{3}=magg23(Index,:);%to modif
phaseg{3}=phaseg23(Index,:);%to modif

for i=1:3

[~,Rwd0,~] = step(env,[0 0 0 0 0 0 0 0 0 0]);
[mag1,phase1,wout1{i}] = bode(env.sys_fb(2,i),w); %to modif
magg1_ref=squeeze(mag1);
phaseg1_ref=squeeze(phase1(1,1,:));


G1_rw_mean=mean(magg{i},1,'omitnan');
G1_ph_mean=mean(wrapTo180(phaseg{i}),1,'omitnan');

k=1.96;
%Ecart type 
%S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
S1=std(magg{i},1,'omitnan');
G1_min=G1_rw_mean-k*S1/(sqrt(size(Index,2)-1));
G1_max=G1_rw_mean+k*S1/(sqrt(size(Index,2)-1));

S1=std(wrapTo180(phaseg{i}),1,'omitnan');
G1_ph_min=G1_ph_mean-k*S1/(sqrt(size(Index,2)-1));
G1_ph_max=G1_ph_mean+k*S1/(sqrt(size(Index,2)-1));

fig=figure
if plot_phase==1
    subplot(2,1,1)
end
hold on 
fill([[350 388], fliplr([350 388])], [-250 -250, 250 250], [0.9290 0.6940 0.1250],'FaceAlpha',0.2,'EdgeColor','none');
fill([w/2/pi, fliplr(w/2/pi)], [20*log10(abs(G1_min)), fliplr(20*log10(abs(G1_max)))], [0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot(w/2/pi  ,20*log10(abs(G1_rw_mean)),'Color',[0 0.4470 0.7410],'LineStyle','-')
plot(w/2/pi, 20*log10(abs(magg1_ref)),'Color','k','LineStyle','--')

%plot(w ,20*log10(abs(magg1_param)),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
grid("on")
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
ylim([-30 15])
xlim([0 1000])

if plot_phase==1
subplot(2,1,2)
hold on 
fill([[350 388], fliplr([350 388])], [-250 -250, 250 250], [0.9290 0.6940 0.1250],'FaceAlpha',0.2,'EdgeColor','none');
fill([w/2/pi, fliplr(w/2/pi)], [G1_ph_min, fliplr(G1_ph_max)], [0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot(w/2/pi  ,wrapTo180(G1_ph_mean),'Color',[0 0.4470 0.7410],'LineStyle','-')
plot(w/2/pi  ,wrapTo180(phaseg1_ref),'Color','k','LineStyle','--')
%plot(w  ,wrapTo180(phaseg1_param),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
grid("on")
xlabel('Frequency (Hz)')
ylabel('Phase (deg)')
xlim([0 1000])
end
    if i==1 && j==1
        name_file ='Figure\Bode_model_DRL_GM_2_1_913';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_1_913_phase' 
        end
    end
    if i==2 && j==1
         name_file ='Figure\Bode_model_DRL_GM_2_2_913';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_2_913_phase' 
        end
    end
    if i==3 && j==1
        name_file ='Figure\Bode_model_DRL_GM_2_3_913';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_3_913_phase' 
        end
    end

     if i==1 && j==2
         name_file ='Figure\Bode_model_DRL_GM_2_1_1317';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_1_1317_phase' 
        end
    end
    if i==2 && j==2
        name_file ='Figure\Bode_model_DRL_GM_2_2_1317';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_2_1317_phase' 
        end
    end
    if i==3 && j==2
        name_file ='Figure\Bode_model_DRL_GM_2_3_1317';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_3_1317_phase' 
        end
    end
     if i==1 && j==3
         name_file ='Figure\Bode_model_DRL_GM_2_1_17';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_1_17_phase' 
        end
    end
    if i==2 && j==3
         name_file ='Figure\Bode_model_DRL_GM_2_2_17';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_2_17_phase' 
        end
    end
    if i==3 && j==3
        name_file ='Figure\Bode_model_DRL_GM_2_3_17';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_3_17_phase' 
        end
    end
    savefig(name_file)
    save_fig_pdf(name_file)
end
end

% Simplex

load(string(path_Simplex)+"extracted_data_240919_simplex_GM.mat")
plot_phase=0 

for j=1:3
    if j==1
        Index=find(Rwd_real>15.5);
    end
    if j==2
        Index=find((Rwd_real<15.5).*(Rwd_real>=13));
    end
    if j==3
        Index=find((Rwd_real<13).*(Rwd_real>20*log10(3)));%
    end

magg{1}=magg21(Index,:);%to modif
phaseg{1}=phaseg21(Index,:);%to modif
magg{2}=magg2(Index,:);%to modif
phaseg{2}=phaseg2(Index,:);%to modif
magg{3}=magg23(Index,:);%to modif
phaseg{3}=phaseg23(Index,:);%to modif

for i=1:3

    if i==1 && j==1
        name_file ='Figure\Bode_model_DRL_GM_2_1_913';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_1_913_phase' 
        end
    end
    if i==2 && j==1
         name_file ='Figure\Bode_model_DRL_GM_2_2_913';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_2_913_phase' 
        end
    end
    if i==3 && j==1
        name_file ='Figure\Bode_model_DRL_GM_2_3_913';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_3_913_phase' 
        end
    end

     if i==1 && j==2
         name_file ='Figure\Bode_model_DRL_GM_2_1_1317';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_1_1317_phase' 
        end
    end
    if i==2 && j==2
        name_file ='Figure\Bode_model_DRL_GM_2_2_1317';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_2_1317_phase' 
        end
    end
    if i==3 && j==2
        name_file ='Figure\Bode_model_DRL_GM_2_3_1317';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_3_1317_phase' 
        end
    end
     if i==1 && j==3
         name_file ='Figure\Bode_model_DRL_GM_2_1_17';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_1_17_phase' 
        end
    end
    if i==2 && j==3
         name_file ='Figure\Bode_model_DRL_GM_2_2_17';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_2_17_phase' 
        end
    end
    if i==3 && j==3
        name_file ='Figure\Bode_model_DRL_GM_2_3_17';
        if plot_phase==1 
            name_file ='Figure\Bode_model_DRL_GM_2_3_17_phase' 
        end
    end
fig=openfig(name_file)
hold on
[~,Rwd0,~] = step(env,[0 0 0 0 0 0 0 0 0 0]);
[mag1,phase1,wout1{i}] = bode(env.sys_fb(2,i),w); %to modif
magg1_ref=squeeze(mag1);
phaseg1_ref=squeeze(phase1(1,1,:));


G1_rw_mean=mean(magg{i},1,'omitnan');
G1_ph_mean=mean(wrapTo180(phaseg{i}),1,'omitnan');

k=1.96;
%Ecart type 
%S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
S1=std(magg{i},1,'omitnan');
G1_min=G1_rw_mean-k*S1/(sqrt(size(Index,2)-1));
G1_max=G1_rw_mean+k*S1/(sqrt(size(Index,2)-1));

S1=std(wrapTo180(phaseg{i}),1,'omitnan');
G1_ph_min=G1_ph_mean-k*S1/(sqrt(size(Index,2)-1));
G1_ph_max=G1_ph_mean+k*S1/(sqrt(size(Index,2)-1));

if plot_phase==1
subplot(2,1,1); 
end
hold on 
fill([w/2/pi, fliplr(w/2/pi)], [20*log10(abs(G1_min)), fliplr(20*log10(abs(G1_max)))], [1 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot(w/2/pi  ,20*log10(abs(G1_rw_mean)),'Color',[1 0.4470 0.7410],'LineStyle','-')
plot(w/2/pi, 20*log10(abs(magg1_ref)),'Color',[0.4660 0.6740 0.1880],'LineStyle','--')

%plot(w ,20*log10(abs(magg1_param)),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
grid("on")
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
ylim([-30 15])
xlim([0 1000])

if plot_phase==1 
subplot(2,1,2)
hold on 
fill([w/2/pi, fliplr(w/2/pi)], [G1_ph_min, fliplr(G1_ph_max)], [1 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot(w/2/pi  ,wrapTo180(G1_ph_mean),'Color',[1 0.4470 0.7410],'LineStyle','-')
plot(w/2/pi  ,wrapTo180(phaseg1_ref),'Color',[0.4660 0.6740 0.1880],'LineStyle','--')
%plot(w  ,wrapTo180(phaseg1_param),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
grid("on")
xlabel('Frequency (rad/sec)')
ylabel('Phase (deg)')
xlim([0 1000*2*pi])
end

   
    savefig(name_file)
    save_fig_pdf(name_file)

end
end

%% Plot training restart continue for 20 of the best DRL init NN

%DRL

%Case
max_episode=5000

for i=1:3

    if i==1
        load(string(path_DRL)+'extracted_data_240919_init_drl_20_GM.mat','trng','env')
    end
    if i==2
        load(string(path_DRL)+'extracted_data_240919_restart_drl_20_GMPM.mat','trng','env')
    end
    if i==3
        load(string(path_DRL)+'extracted_data_240919_continue_drl_20_GMPM.mat','trng','env')
    end


k=1.96;
N=19%length(trng)
T = NaN(N,max_episode);
Reward = array2table(T);
AVGReward = array2table(T);



if i==3 
    for l=1:N
        Reward(l,:)=array2table(trng{1,l}.trainingStats_TRPO_2.EpisodeReward(:)');
        AVGReward(l,:)=array2table(trng{1,l}.trainingStats_TRPO_2.EpisodeReward(:)');
    end
else
    for l=1:N
        Reward(l,:)=array2table(trng{1,l}.trainingStats_TRPO.EpisodeReward(:)');
        AVGReward(l,:)=array2table(trng{1,l}.trainingStats_TRPO.EpisodeReward(:)');
    end
end

%Moyenne
Reward=table2array(Reward);
AVGReward=table2array(AVGReward);
%Ep_rw_mean=mean(Reward(1:3+7:10,:),1,'omitnan');

Ep_rw_mean=mean(Reward,1,'omitnan');%mean(Reward(Index,:),1,'omitnan');
%Ecart type 
%S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
S=std(Reward,1,'omitnan');%std(Reward(Index,:),1,'omitnan');
Rwd_min=Ep_rw_mean-k*S/(sqrt(N-1));
Rwd_max=Ep_rw_mean+k*S/(sqrt(N-1));


fig=figure
%subplot(2,1,1)
hold on
fill([1 : max_episode, fliplr(1 : max_episode)], [Rwd_min, fliplr(Rwd_max)], [0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot([1: 20 :max_episode]  ,Ep_rw_mean(1: 20 :end)','Color',[0 0.4470 0.7410],'LineStyle','-')
%plot([1: max_episode]  ,Ep_rw_mean(1:end)','Color',[0 0.4470 0.7410])
xlabel('Episode Number')
ylabel('Episode Reward')

K_opt_pre=-4e5
Xi_opt_pre=0.23
Ome_opt_pre=2.3876e3
Action_opt_pre_scaled=[ (log10(-K_opt_pre)/10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre/(1000*2*pi)-1/2)*2*10];
[~,Rwd_real_pr,~] = step(env,[Action_opt_pre_scaled; Action_opt_pre_scaled; Action_opt_pre_scaled]);

plot([1 max_episode],[Rwd_real_pr Rwd_real_pr],'Color','k','LineStyle','-.')
hold on

K_opt_pre=[0 0 0]
Xi_opt_pre=[0.3663 0.1 0.2844]
Ome_opt_pre=[2.5788e3 4.4911e3 2.2619e3]
Action_opt_pre_scaled=[ (log10(-K_opt_pre)./10-1/2)*2*10 (Xi_opt_pre-1/2)*2*10 (Ome_opt_pre./(1000*2*pi)-1/2)*2*10];
[~,Rwd_0,~] = step(env,[Action_opt_pre_scaled]);
plot([1 max_episode],[Rwd_0 Rwd_0],'Color','k','LineStyle','--')
ylim([-1 20])
legend('Std Reward','Mean Reward','Reward hand-adjusted controler','Reward control off','Location','southeast')

    if i==1
        savefig('Figure\Training_Reward_var_best_20_init')
        save_fig_pdf('Figure\Training_Reward_var_best_20_init')
    end
    if i==2
        savefig('Figure\Training_Reward_var_best_20_restart')
        save_fig_pdf('Figure\Training_Reward_var_best_20_restart')
    end
    if i==3
        savefig('Figure\Training_Reward_var_best_20_continue')
        save_fig_pdf('Figure\Training_Reward_var_best_20_continue')
    end

end

% Simplex

for j=1:3
    if j==1
        clear Reward
        load(string(path_Simplex)+'extracted_data_240919_init_simplex_20_GM.mat')
    end
    if j==2
        clear Reward
        load(string(path_Simplex)+'extracted_data_240919_restart_simplex_20_GMPM.mat')
    end
    if j==3
        clear Reward
        load(string(path_Simplex)+'extracted_data_240919_continue_simplex_20_GMPM.mat')
    end

    if j==1 
        name_fig='Figure\Training_Reward_var_best_20_init';
    end
    if j==2 
        name_fig='Figure\Training_Reward_var_best_20_restart';
    end
    if j==3 
        name_fig='Figure\Training_Reward_var_best_20_continue';    
    end

    fig=openfig(name_fig)

Reward=Rwd_real;
max_episode=5000

k=1.96;
Ep_rw_mean=mean(Reward,2,'omitnan');%mean(Reward(Index,:),1,'omitnan');
%Ecart type 
%S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
S=std(Reward,1,'omitnan');%std(Reward(Index,:),1,'omitnan');
Rwd_min=Ep_rw_mean-k*S/(sqrt(size(Reward,2)-1));
Rwd_max=Ep_rw_mean+k*S/(sqrt(size(Reward,2)-1));

hold on   
fill([[1  max_episode], fliplr([1 max_episode])], [[Rwd_min Rwd_min], fliplr([Rwd_max Rwd_max])], [1 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot([1 max_episode]  , [Ep_rw_mean Ep_rw_mean],'Color',[1 0.4470 0.7410],'LineStyle','-')

hold on
legend('Std Reward DRL','Mean Reward DRL','Reward hand-adjusted controler','Reward control off','Std Reward Simplex','Mean Reward Simplex','Location','southeast')

    savefig(name_fig)
    save_fig_pdf(name_fig)

end 


%% Plot bode large freq

clc
clear all
close all


path_Simplex="Data\Training\Simplex\processed\"
path_DRL="Data\Training\DRL_TRPO\processed\"

for j=1:3
    

    if j==1
        load(string(path_DRL)+'extracted_data_240919_init_drl_20_GM.mat')
    end
    if j==2
        load(string(path_DRL)+'extracted_data_240919_restart_drl_20_GMPM.mat')
    end
    if j==3
        load(string(path_DRL)+'extracted_data_240919_continue_drl_20_GMPM.mat')
    end

    N=size(magg21,1)

magg{1}=magg21;%to modif
phaseg{1}=phaseg21;%to modif
magg{2}=magg2;%to modif
phaseg{2}=phaseg2;%to modif
magg{3}=magg23;%to modif
phaseg{3}=phaseg23;%to modif

for i=1:3

[~,Rwd0,~] = step(env,[0 0 0 0 0 0 0 0 0 0]);
[mag1,phase1,wout1{i}] = bode(env.sys_fb(2,i),w); %to modif
magg1_ref=squeeze(mag1);
phaseg1_ref=squeeze(phase1(1,1,:));


G1_rw_mean=mean(magg{i},1,'omitnan');
G1_ph_mean=mean(wrapTo180(phaseg{i}),1,'omitnan');

k=1.96;
%Ecart type 
%S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
S1=std(magg{i},1,'omitnan');
G1_min=G1_rw_mean-k*S1/(sqrt(N-1));
G1_max=G1_rw_mean+k*S1/(sqrt(N-1));

S1=std(wrapTo180(phaseg{i}),1,'omitnan');
G1_ph_min=G1_ph_mean-k*S1/(sqrt(N-1));
G1_ph_max=G1_ph_mean+k*S1/(sqrt(N-1));

fig=figure
subplot(2,1,1)
hold on 
fill([[350 388], fliplr([350 388])], [-250 -250, 250 250], [0.9290 0.6940 0.1250],'FaceAlpha',0.2,'EdgeColor','none');
fill([w/2/pi, fliplr(w/2/pi)], [20*log10(abs(G1_min)), fliplr(20*log10(abs(G1_max)))], [0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot(w/2/pi  ,20*log10(abs(G1_rw_mean)),'Color',[0 0.4470 0.7410],'LineStyle','-')
plot(w/2/pi, 20*log10(abs(magg1_ref)),'Color','k','LineStyle','--')

%plot(w ,20*log10(abs(magg1_param)),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
grid("on")
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
ylim([-30 15])
xlim([0 1000])
subplot(2,1,2)
hold on 
fill([[350 388], fliplr([350 388])], [-250 -250, 250 250], [0.9290 0.6940 0.1250],'FaceAlpha',0.2,'EdgeColor','none');
fill([w/2/pi, fliplr(w/2/pi)], [G1_ph_min, fliplr(G1_ph_max)], [0 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
plot(w/2/pi  ,wrapTo180(G1_ph_mean),'Color',[0 0.4470 0.7410],'LineStyle','-')
plot(w/2/pi  ,wrapTo180(phaseg1_ref),'Color','k','LineStyle','--')
%plot(w  ,wrapTo180(phaseg1_param),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
grid("on")
xlabel('Frequency (Hz)')
ylabel('Phase (deg)')
xlim([0 1000])

    if i==1 && j==1
        savefig('Figure\Bode_model_drl_GM_2_1_best20_init')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_1_best20_init')
    end
    if i==2 && j==1
        savefig('Figure\Bode_model_drl_GM_2_2_best20_init')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_2_best20_init')
    end
    if i==3 && j==1
        savefig('Figure\Bode_model_drl_GM_2_3_best20_init')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_3_best20_init')
    end
    if i==1 && j==2
        savefig('Figure\Bode_model_drl_GM_2_1_best20_restart')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_1_best20_restart')
    end
    if i==2 && j==2
        savefig('Figure\Bode_model_drl_GM_2_2_best20_restart')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_2_best20_restart')
    end
    if i==3 && j==2
        savefig('Figure\Bode_model_drl_GM_2_3_best20_restart')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_3_best20_restart')
    end
     if i==1 && j==3
        savefig('Figure\Bode_model_drl_GM_2_1_best20_continue')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_1_best20_continue')
    end
    if i==2 && j==3
        savefig('Figure\Bode_model_drl_GM_2_2_best20_continue')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_2_best20_continue')
    end
    if i==3 && j==3
        savefig('Figure\Bode_model_drl_GM_2_3_best20_continue')
        save_fig_pdf('Figure\Bode_model_drl_GM_2_3_best20_continue')
    end

end
end

% Simplex

for j=1:3

    if j==1
        load(string(path_Simplex)+'extracted_data_240919_init_simplex_20_GM.mat')
    end
    if j==2
        load(string(path_Simplex)+'extracted_data_240919_restart_simplex_20_GMPM.mat')
    end
    if j==3
        load(string(path_Simplex)+'extracted_data_240919_continue_simplex_20_GMPM.mat')
    end

    N=length(Opti_val)

    magg{1}=magg21;%to modif
    phaseg{1}=phaseg21;%to modif
    magg{2}=magg2;%to modif
    phaseg{2}=phaseg2;%to modif
    magg{3}=magg23;%to modif
    phaseg{3}=phaseg23;%to modif
    
    for i=1:3

        [~,Rwd0,~] = step(env,[0 0 0 0 0 0 0 0 0 0]);
        [mag1,phase1,wout1{i}] = bode(env.sys_fb(2,i),w); %to modif
        magg1_ref=squeeze(mag1);
        phaseg1_ref=squeeze(phase1(1,1,:));
        
        
        G1_rw_mean=mean(magg{i},1,'omitnan');
        G1_ph_mean=mean(wrapTo180(phaseg{i}),1,'omitnan');
        
        k=1.96;
        %Ecart type 
        %S=sqrt(1/N*sum((Reward-Ep_rw_mean).^2))
        S1=std(magg{i},1,'omitnan');
        G1_min=G1_rw_mean-k*S1/(sqrt(N-1));
        G1_max=G1_rw_mean+k*S1/(sqrt(N-1));
        
        S1=std(wrapTo180(phaseg{i}),1,'omitnan');
        G1_ph_min=G1_ph_mean-k*S1/(sqrt(N-1));
        G1_ph_max=G1_ph_mean+k*S1/(sqrt(N-1));
    
        if i==1 && j==1
            name_fig = 'Figure\Bode_model_drl_GM_2_1_best20_init'
        end
        if i==2 && j==1
            name_fig = 'Figure\Bode_model_drl_GM_2_2_best20_init'
        end
        if i==3 && j==1
            name_fig = 'Figure\Bode_model_drl_GM_2_3_best20_init'
        end
        if i==1 && j==2
            name_fig = 'Figure\Bode_model_drl_GM_2_1_best20_restart'
        end
        if i==2 && j==2
            name_fig = 'Figure\Bode_model_drl_GM_2_2_best20_restart'
        end
        if i==3 && j==2
            name_fig = 'Figure\Bode_model_drl_GM_2_3_best20_restart'
        end
         if i==1 && j==3
            name_fig = 'Figure\Bode_model_drl_GM_2_1_best20_continue'
        end
        if i==2 && j==3
            name_fig = 'Figure\Bode_model_drl_GM_2_2_best20_continue'
        end
        if i==3 && j==3
            name_fig = 'Figure\Bode_model_drl_GM_2_3_best20_continue'
        end

        fig=openfig(name_fig)
        
        subplot(2,1,1)
        hold on 
        fill([w/2/pi, fliplr(w/2/pi)], [20*log10(abs(G1_min)), fliplr(20*log10(abs(G1_max)))], [1 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
        plot(w/2/pi  ,20*log10(abs(G1_rw_mean)),'Color',[1 0.4470 0.7410],'LineStyle','-')
        %plot(w/2/pi, 20*log10(abs(magg1_ref)),'Color',[0.4660 0.6740 0.1880],'LineStyle','--')
        
        %plot(w ,20*log10(abs(magg1_param)),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
        grid("on")
        xlabel('Frequency (Hz)')
        ylabel('Magnitude (dB)')
        ylim([-30 15])
        xlim([0 1000])
        subplot(2,1,2)
        hold on 
        fill([w/2/pi, fliplr(w/2/pi)], [G1_ph_min, fliplr(G1_ph_max)], [1 0.4470 0.7410],'FaceAlpha',0.2,'EdgeColor','none');
        plot(w/2/pi  ,wrapTo180(G1_ph_mean),'Color',[1 0.4470 0.7410],'LineStyle','-')
        %plot(w/2/pi  ,wrapTo180(phaseg1_ref),'Color',[0.4660 0.6740 0.1880],'LineStyle','--')
        %plot(w  ,wrapTo180(phaseg1_param),'Color',[0.8500 0.3250 0.0980],'LineStyle','-.')
        grid("on")
        xlabel('Frequency (Hz)')
        ylabel('Phase (deg)')
        xlim([0 1000])
        
        legend('Target band','Std (DRL)','Mean (DRL)','Control off','Std (Simplex)','Mean (Simplex)','Location','southeast')

        savefig(name_fig)
        save_fig_pdf(name_fig)
        
    end
end


%%
function save_fig_pdf(fig_title)

    fig=openfig(fig_title);
    set(fig,'Visible','on')
    
    fig.Units = 'centimeters';        % set figure units to cm
    fig.PaperUnits = 'centimeters';   % set pdf printing paper units to cm
    fig.PaperSize = fig.Position(3:4);
    pdf_file_name = [fig_title, '.pdf'];
    %print -dpdf -painters fig_title
    print(fig, '-dpdf', '-painters', pdf_file_name);
end
