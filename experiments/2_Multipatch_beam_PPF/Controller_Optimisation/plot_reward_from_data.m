% Import data
clc
clear all
close all

load('Data/Reward/Reward_param_GMPM_2024_10_04_18_40_54_094.mat')

%% Plot reward var with K omega fix

marker=['o';'d';'*';'.';'x';'s';'^';'v';'>';'<';'p';'h'];
l=1;

omega=380*2*pi/(1000*2*pi)
scale_val=(380*2*pi/(1000*2*pi)-1/2)*2*10
[V I]=find(Action_test_ome>scale_val,1,'first')

search_index=[-5 -1 4 7]
for i=1:length(search_index)
    [V I2(i)]=find(Action_test_xi==search_index(i))
end

figure
hold on
i=I%1:length(Action_test_ome)
for j=I2%2:3:length(Action_test_xi)
        plot(log10(-10.^((Action_test_k./10./2+1/2)*10)),reshape(Rwd(i,j,:),[1 length(Rwd(i,j,:))]),'Marker',marker(l))
        l=l+1
end
legend("\xi= "+num2str((Action_test_xi(I2)./10./2+1/2)'))
xlabel('log_{10}(K_c)')
ylabel('Reward')
grid on
%%
namefig="Figure/Reward_var_omega_380Hz_GMPM";
savefig(namefig);
save_fig_pdf(convertStringsToChars(namefig));

%% Plot reward var with K xi fix

marker=['.';'.';'d';'d';'*';'*';'o';'o';'x';'x';'s';'s';'^';'^';'v';'v';'>';'>';'<';'<';'p';'p';'h';'h'];
l=1;

% Number of colors in the transition
num_colors = length(Action_test_ome);

% Generate RGB values for red and blue
red_rgb = [1, 0, 0]; % Red color (RGB)
blue_rgb = [0, 0, 1]; % Blue color (RGB)

% Interpolate between red and blue to create the color array
color_array = zeros(num_colors, 3);
for i = 1:num_colors
    color_array(i, :) = (i-1) / (num_colors-1) * blue_rgb + (num_colors-i) / (num_colors-1) * red_rgb;
end

omega=380*2*pi/(1000*2*pi)
scale_val=(380*2*pi/(1000*2*pi)-1/2)*2*10
[V I]=find(Action_test_ome>scale_val,1,'first')


search_index=-1
[V I3]=find(Action_test_xi==search_index)
(V./10./2+1/2)

figure
hold on
j=I3;
for i=[9:2:length(Action_test_ome)-3]%2:3:length(Action_test_xi)
        plot(log10(-10.^((Action_test_k./10./2+1/2)*10)),reshape(Rwd(i,j,:),[1 length(Rwd(i,j,:))]),'Color',color_array(i, :),'Marker',marker(i))
        l=l+1
end
legend("\omega= "+num2str(round(((Action_test_ome./10./2+1/2)*1000*2*pi)')))
xlabel('log_{10}(K_c)')
ylabel('Reward')
grid on

%%
namefig="Figure/Reward_var_xi_0_55_GMPM";
savefig(namefig);
save_fig_pdf(convertStringsToChars(namefig));

%%
clc
clear all
close all
load('Data/Reward/Reward_param_GM_2024_10_04_18_40_52_383.mat')
Rwd((Rwd(:,:,:)<0))=-1
%% Plot reward var with K omega fix

marker=['o';'d';'*';'.';'x';'s';'^';'v';'>';'<';'p';'h'];
l=1;

omega=380*2*pi/(1000*2*pi)
scale_val=(380*2*pi/(1000*2*pi)-1/2)*2*10
[V I]=find(Action_test_ome>scale_val,1,'first')

search_index=[-5 -1 4 7]
for i=1:length(search_index)
    [V I2(i)]=find(Action_test_xi==search_index(i))
end

figure
hold on
i=I%1:length(Action_test_ome)
for j=I2%2:3:length(Action_test_xi)
        plot(log10(-10.^((Action_test_k./10./2+1/2)*10)),reshape(Rwd(i,j,:),[1 length(Rwd(i,j,:))]),'Marker',marker(l))
        l=l+1
end
legend("\xi= "+num2str((Action_test_xi(I2)./10./2+1/2)'))
xlabel('log_{10}(K_c)')
ylabel('Reward')
grid on

% Create textbox
annotation('textbox',...
    [0.620357142857143 0.201428571428572 0.0414285714285709 0.723809523809523],...
    'LineStyle','-.',...
    'FitBoxToText','off');

% Create textbox
annotation('textbox',...
    [0.566071428571428 0.194714284760612 0.0614285714285714 0.0638095247631983],...
    'String',{'(5)'},...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.406785714285713 0.866142856189187 0.0614285714285717 0.0638095247631986],...
    'String','(1)',...
    'FitBoxToText','off',...
    'EdgeColor','none');
% Create textbox
annotation('textbox',...
    [0.757857142857142 0.203809523809524 0.0799999999999996 0.0409047619047653],...
    'String','(3)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.693928571428567 0.521380951427282 0.0635714285714303 0.0638095247631989],...
    'String','(2)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.367142857142856 0.197142857142858 0.0799999999999997 0.0409047619047654],...
    'String','(4)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

%%
namefig="Figure/Reward_var_omega_380Hz_GM";
savefig(namefig);
save_fig_pdf(convertStringsToChars(namefig));

%% Plot reward var with K xi fix

marker=['.';'.';'d';'d';'*';'*';'o';'o';'x';'x';'s';'s';'^';'^';'v';'v';'>';'>';'<';'<';'p';'p';'h';'h'];
l=1;

% Number of colors in the transition
num_colors = length(Action_test_ome);

% Generate RGB values for red and blue
red_rgb = [1, 0, 0]; % Red color (RGB)
blue_rgb = [0, 0, 1]; % Blue color (RGB)

% Interpolate between red and blue to create the color array
color_array = zeros(num_colors, 3);
for i = 1:num_colors
    color_array(i, :) = (i-1) / (num_colors-1) * blue_rgb + (num_colors-i) / (num_colors-1) * red_rgb;
end

omega=380*2*pi/(1000*2*pi)
scale_val=(380*2*pi/(1000*2*pi)-1/2)*2*10
[V I]=find(Action_test_ome>scale_val,1,'first')


search_index=-1
[V I3]=find(Action_test_xi==search_index)
(V./10./2+1/2)

figure
hold on
j=I3;
for i=[9:2:length(Action_test_ome)-3]%2:3:length(Action_test_xi)
        plot(log10(-10.^((Action_test_k./10./2+1/2)*10)),reshape(Rwd(i,j,:),[1 length(Rwd(i,j,:))]),'Color',color_array(i, :),'Marker',marker(i))
        l=l+1
end
legend("\omega= "+num2str(round(((Action_test_ome./10./2+1/2)*1000*2*pi)')))
xlabel('log_{10}(K_c)')
ylabel('Reward')
grid on

% Create textbox
annotation('textbox',...
    [0.406785714285713 0.866142856189187 0.0614285714285717 0.0638095247631986],...
    'String','(1)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.757857142857142 0.203809523809524 0.0799999999999996 0.0409047619047653],...
    'String','(3)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.693928571428567 0.521380951427282 0.0635714285714303 0.0638095247631989],...
    'String','(2)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.367142857142856 0.197142857142858 0.0799999999999997 0.0409047619047654],...
    'String','(4)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

%%
namefig="Figure/Reward_var_xi_0_55_GM";
savefig(namefig);
save_fig_pdf(convertStringsToChars(namefig));

%% Plot reward var with xi K fix

marker=['.';'.';'d';'d';'*';'*';'o';'o';'x';'x';'s';'s';'^';'^';'v';'v';'>';'>';'<';'<';'p';'p';'h';'h'];
l=1;

% Number of colors in the transition
num_colors = length(Action_test_xi);

% Generate RGB values for red and blue
red_rgb = [1, 0, 0]; % Red color (RGB)
blue_rgb = [0, 0, 1]; % Blue color (RGB)

% Interpolate between red and blue to create the color array
color_array = zeros(num_colors, 3);
for i = 1:num_colors
    color_array(i, :) = (i-1) / (num_colors-1) * blue_rgb + (num_colors-i) / (num_colors-1) * red_rgb;
end

omega=380*2*pi/(1000*2*pi)
scale_val=(380*2*pi/(1000*2*pi)-1/2)*2*10
[V I1]=find(Action_test_ome>scale_val,1,'first')

search_index=6
[V I3]=find(real(log10(-10.^((Action_test_k./10./2+1/2)*10)))==search_index)
log10(-10.^((V./10./2+1/2)*10))

figure
hold on
k=I3;

for i=[9:2:length(Action_test_xi)-3]%2:3:length(Action_test_xi)
        plot(Action_test_xi./10./2+1/2,reshape(Rwd(i,:,k),[1 length(Rwd(i,:,k))]),'Color',color_array(i, :),'Marker',marker(i))
        l=l+1
end
legend("\omega= "+num2str(round(((Action_test_ome./10./2+1/2)*1000*2*pi)')))
xlabel('\xi')
ylabel('Reward')
grid on

% Create textbox
annotation('textbox',...
    [0.406785714285713 0.866142856189187 0.0614285714285717 0.0638095247631986],...
    'String','(1)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.757857142857142 0.203809523809524 0.0799999999999996 0.0409047619047653],...
    'String','(3)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.693928571428567 0.521380951427282 0.0635714285714303 0.0638095247631989],...
    'String','(2)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.367142857142856 0.197142857142858 0.0799999999999997 0.0409047619047654],...
    'String','(4)',...
    'FitBoxToText','off',...
    'EdgeColor','none');
%%
namefig="Figure/Reward_var_K_E6_GM";
savefig(namefig);
save_fig_pdf(convertStringsToChars(namefig));

%%

marker=['.';'.';'d';'d';'*';'*';'o';'o';'x';'x';'s';'s';'^';'^';'v';'v';'>';'>';'<';'<';'p';'p';'h';'h'];
l=1;

% Number of colors in the transition
num_colors = length(Action_test_xi);

% Generate RGB values for red and blue
red_rgb = [1, 0, 0]; % Red color (RGB)
blue_rgb = [0, 0, 1]; % Blue color (RGB)

% Interpolate between red and blue to create the color array
color_array = zeros(num_colors, 3);
for i = 1:num_colors
    color_array(i, :) = (i-1) / (num_colors-1) * blue_rgb + (num_colors-i) / (num_colors-1) * red_rgb;
end

search_index=-1
[V I1]=find(Action_test_xi==search_index)
(V./10./2+1/2)

search_index=6
[V I3]=find(real(log10(-10.^((Action_test_k./10./2+1/2)*10)))==search_index)
log10(-10.^((V./10./2+1/2)*10))

figure
hold on
k=I3;
I2=[9:2:length(Action_test_xi)-3];
for j=I2%2:3:length(Action_test_xi)
        plot(((Action_test_ome./10./2+1/2)*1000*2*pi),reshape(Rwd(:,j,k),[1 length(Rwd(:,j,k))]),'Color',color_array(j, :),'Marker',marker(j))
        l=l+1
end
legend("\xi= "+num2str((Action_test_xi(I2)./10./2+1/2)'))
xlabel('\omega')
ylabel('Reward')
grid on

% Create textbox
annotation('textbox',...
    [0.406785714285713 0.866142856189187 0.0614285714285717 0.0638095247631986],...
    'String','(1)',...
    'FitBoxToText','off',...
    'EdgeColor','none');


% Create textbox
annotation('textbox',...
    [0.757857142857142 0.203809523809524 0.0799999999999996 0.0409047619047653],...
    'String','(3)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.693928571428567 0.521380951427282 0.0635714285714303 0.0638095247631989],...
    'String','(2)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% Create textbox
annotation('textbox',...
    [0.367142857142856 0.197142857142858 0.0799999999999997 0.0409047619047654],...
    'String','(4)',...
    'FitBoxToText','off',...
    'EdgeColor','none');

xlim([0,1000*2*pi])
%%
namefig="Figure/Reward_var_ome_K_E6_GM";
savefig(namefig);
save_fig_pdf(convertStringsToChars(namefig));
