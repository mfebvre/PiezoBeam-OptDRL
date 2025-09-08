clc
clear all
close all

%%Indicate path to identified model
path_id='../Model_Identification/Data/processed/';

%%Import data
load(string(path_id)+'sys_id.mat')
load('Data/processed/frf_mesure_crtl_PPF_multi.mat','FRF_mesure','V','Y','C','K_value','Xi_value','Ome_value')

save_fig = 1; % = 1 save figures % = 0 not save figures

%% Plot bode response from Pai to Psj with PPF control 

s=tf([1 0],[0 1])
bopts= bodeoptions;
bopts.FreqUnits='Hz';               
bopts.FreqScale='linear';
bopts.PhaseWrapping='on';
bopts.XLim={[250,450]};
bopts.XLim={[20,1000]};
bopts.MagLowerLimMode='manual';
bopts.MagLowerLim=-25;
%bopts.YLim={[-50,20]};

defaultColors = ['b'; 'r'; 'y'; 'g'; 'c'; 'm';'b'; 'r'];
defaultColors = ['b';'r'; 'r';'y'; 'y'; 'g';'g'; 'c'; 'c';'m';'m';'k';'k'];


wint=10:0.01:1000*2*pi;


j=2 % Pai

for i=1:3 % Psj
    fig = figure
    subplot(2,1,1)
    hold on
    subplot(2,1,2)
    hold on
    for k=[1 2:2:size(FRF_mesure,2)-1]
       
        Control=[C(k) 0 0;
                 0 C(k) 0;
                 0 0 C(k)]*1000*2*pi/(s+1000*2*pi);
    
        tf_fb{k}=feedback(sys_tf,-Control,[1 2 3],[1 2 3],-1);    
           
        [magg1,phaseg1,wout] = bode(tf_fb{k}(j,i),wint);
        magg1=squeeze(magg1); phaseg1=squeeze(phaseg1); wout=squeeze(wout);
    
        subplot(2,1,1)
        hold on
        plot(wout/2/pi,20*log10(magg1),"LineStyle",'-',"Color",defaultColors(k))
        subplot(2,1,2)
        plot(wout/2/pi,wrapTo180(phaseg1),"LineStyle",'-',"Color",defaultColors(k))
        hold on 
    
        if i<j
            norms_Hinf_est21(k)=norm(magg1,Inf)
            norms_H2_est21(k)=norm(magg1,2)
        elseif i==j
            norms_Hinf_est22(k)=norm(magg1,Inf)
            norms_H2_est22(k)=norm(magg1,2)
        else
            norms_Hinf_est23(k)=norm(magg1,Inf)
            norms_H2_est23(k)=norm(magg1,2)
        end
        [magg1,phaseg1,wout] = bode(FRF_mesure{k}(j,i),wint);
        magg1=squeeze(magg1); phaseg1=squeeze(phaseg1); wout=squeeze(wout);
        
        subplot(2,1,1)
        hold on
        plot(wout/2/pi,20*log10(magg1),'--',"Color",defaultColors(k))
        subplot(2,1,2)
        plot(wout/2/pi,wrapTo180(phaseg1),"LineStyle",'--',"Color",defaultColors(k))
        hold on
    
        if i<j
            norms_Hinf_mes21(k)=norm(magg1,Inf)
            norms_H2_mes21(k)=norm(magg1,2)
        elseif i==j
            norms_Hinf_mes22(k)=norm(magg1,Inf)
            norms_H2_mes22(k)=norm(magg1,2)
        else
            norms_Hinf_mes23(k)=norm(magg1,Inf)
            norms_H2_mes23(k)=norm(magg1,2)
        end    
    
    end
    
    fontsize(fig,12,"points")
    subplot(2,1,2)
    grid on
    legend('K='+string(K_value),'Location','northeastoutside','Visible','off')
    ylim([-195 195])
    ylabel('Phase (deg)')
    xlabel('Frequency (Hz)')
    subplot(2,1,1)
    grid on
    legend('K='+string(K_value),'Location','eastoutside')
    ylim([-50 20])
    ylabel('Magnitude (dB)')
    xlabel('Frequency (Hz)')
    
    if save_fig == 1
        namefig=sprintf('Figure/Sys_id_mes_mod_crtl_PPF_multi_%d_%d',j,i);
        savefig(namefig);
        save_fig_pdf(namefig);
    end
    close all
end
%% Model testbench error estimation

Abs_error_mes_mod21=(norms_Hinf_mes21-norms_Hinf_est21)./norms_Hinf_mes21
Abs_error_mes_mod22=(norms_Hinf_mes22-norms_Hinf_est22)./norms_Hinf_mes22
Abs_error_mes_mod23=(norms_Hinf_mes23-norms_Hinf_est23)./norms_Hinf_mes23

Abs_error_mes_mod21_2=abs(norms_H2_mes21-norms_H2_est21)./norms_H2_mes21
Abs_error_mes_mod22_2=abs(norms_H2_mes22-norms_H2_est22)./norms_H2_mes22
Abs_error_mes_mod23_2=abs(norms_H2_mes23-norms_H2_est23)./norms_H2_mes23

[K_value(2:end-1)' Abs_error_mes_mod21' Abs_error_mes_mod22' Abs_error_mes_mod23']
[K_value(2:end-1)' Abs_error_mes_mod21_2' Abs_error_mes_mod22_2' Abs_error_mes_mod23_2']
