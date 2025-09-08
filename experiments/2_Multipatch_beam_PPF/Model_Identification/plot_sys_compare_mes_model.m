clc
clear all
close all

fig_to_save = 1 % = 1 to save; = 1 to not save

%% Plot Transfert functions

load("Data/processed/sys_id.mat")

bopts= bodeoptions;
bopts.FreqUnits='Hz';
bopts.FreqScale='linear';
bopts.PhaseWrapping='on';
bopts.XLim={[0,1600]};
bopts.MagLowerLimMode='manual';
bopts.MagLowerLim=-50;


for i=1:3
    for j=1:3
        fig=figure()
        bode(FRF_mesure(i,j),bopts)
        hold on
        bode(sys_tf(i,j),bopts)
        grid on
        namefig="Figure/Sys_id_mes_mod_"+num2str(i)+"_"+num2str(j);
        fontsize(fig,12,"points")
        if fig_to_save == 1
            savefig(namefig);
            save_fig_pdf(convertStringsToChars(namefig));
        end
    end
end

%% Plot Coherence

load('Data/processed/data_extracted_from_measurement_for_id.mat')
for i=1:3
    for j=1:3
        fig = figure
        fig.Position=[488 438 560 420/2]
        plot(fs{1,j},cs{i,j})
        grid on
        xlim([0 1600])
        fontsize(fig,12,"points")
        namefig="Figure/Coherence_"+num2str(i)+"_"+num2str(j);
        if fig_to_save == 1
            savefig(namefig);
            save_fig_pdf(convertStringsToChars(namefig));
        end
    end
end


%% Plot time response
close all
%load("input_data_sys_cluster.mat")

load("Data/processed/data_extracted_from_measurement_for_id.mat")

time=[0:1:length(V(1,:))-6]*1/10000;

Y_tf1=lsim(sys_tf,V(:,1:end-5)',time');

Y_cd = lowpass(Y_c',1000,10000);
Y_tf1d = lowpass(Y_tf1(2:end,:),1000,10000);

time=time(1:end-1);

fig = figure
hold on
plot(time,Y_cd(:,1),'LineWidth',2)
plot(time,Y_tf1d(:,1)','LineWidth',2,'LineStyle','--')
xlim([6 6.02])
ylabel('Ps_1 (V)')
xlabel('time (s)')
ylim([-20 20])
grid on
namefig="Figure/Time_Ps1_zoom"
fontsize(fig,12,"points")
if fig_to_save == 1
    savefig(namefig);
    save_fig_pdf(convertStringsToChars(namefig));
end

fig = figure
hold on
plot(time,Y_cd(:,2),'LineWidth',2)
plot(time,Y_tf1d(:,2)','LineWidth',2,'LineStyle','--')
xlim([6 6.02])
ylabel('Ps_2 (V)')
xlabel('time (s)')
ylim([-20 20])
grid on
namefig="Figure/Time_Ps2_zoom"
fontsize(fig,12,"points")
if fig_to_save == 1
    savefig(namefig);
    save_fig_pdf(convertStringsToChars(namefig));
end

fig = figure
hold on
plot(time,Y_cd(:,3),'LineWidth',2)
plot(time,Y_tf1d(:,3)','LineWidth',2,'LineStyle','--')
xlim([6 6.02])
xlabel('time (s)')
ylabel('Ps_3 (V)')
ylim([-20 20])
grid on
namefig="Figure/Time_Ps3_zoom"
fontsize(fig,12,"points")
if fig_to_save == 1
    savefig(namefig);
    save_fig_pdf(convertStringsToChars(namefig));
end