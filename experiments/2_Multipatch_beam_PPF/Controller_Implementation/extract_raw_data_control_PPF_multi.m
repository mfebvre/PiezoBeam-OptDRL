clc
clear all
close all

path="Data/raw/";

%all loop
load_files=["rec1_053.mat";...
    "rec1_062.mat";...
    "rec1_063.mat";...
    "rec1_064.mat";...
    "rec1_065.mat";...
    "rec1_066.mat";...
    "rec1_067.mat";...
    "rec1_068.mat";...
    "rec1_069.mat";...
    "rec1_070.mat";...
    "rec1_071.mat";...
    "rec1_072.mat"]
% 
s=tf([1 0],[0 1])

K_value=[0 5e4 1e5 2e5 3e5 4e5 5e5 6e5 8e5 1e6 2e6 3e6];
Xi_value=[0.23];
Ome_value=[380*2*pi];

C=K_value/(s^2+2*Xi_value*Ome_value*s+Ome_value^2);


for i=1:length(load_files)
    S=importdata(string(path)+string(load_files(i)));
        
    x_wn=S.X.Data;
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/Ps1'))));
    Ps1=S.Y(Index).Data;
        
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/Ps2'))));
    Ps2=S.Y(Index).Data;
    
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/Ps3'))));
    Ps3=S.Y(Index).Data;
        
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/VP1'))));
    Vp1=S.Y(Index).Data;    
    
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/VP2'))));
    Vp2=S.Y(Index).Data;
    
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/VP3'))));
    Vp3=S.Y(Index).Data;
    
    if i==1
        [~,I]=find(x_wn>30,1,'first');
    end

    time_mes(i,:)=x_wn(1:I);
    Y{1,i}=detrend(Ps1(1:I));
    Y{2,i}=detrend(Ps2(1:I));
    Y{3,i}=detrend(Ps3(1:I));
    V{1,i}=detrend(Vp1(1:I));
    V{2,i}=detrend(Vp2(1:I));
    V{3,i}=detrend(Vp3(1:I));

end

time=[0:1:length(time_mes(1,:))-1]*1/10000;
Fs=10000;

for k=1:length(load_files)
    for j=1:3
        Yd{j,k}=interp1(time, Y{j,k},time_mes(j,:));
        Vd{j,k}=interp1(time, V{j,k},time_mes(j,:));
    end
end

bopts= bodeoptions;
bopts.FreqUnits='Hz';
bopts.FreqScale='linear';
bopts.PhaseWrapping='on';
bopts.XLim={[0,1500]};
%bopts.YLim={[-50,20]};

for k=1:length(load_files)
    for i=1:3
        for j=1:3
             
            [txy{k}(i,j,:),f] = tfestimate(V{i,k},Y{j,k},[],[],[],Fs);
            FRF_mesure{k}(i,j) = frd(txy{k}(i,j,:),f*2*pi);
            
        end 
    end
end
        
save('Data/processed/frf_mesure_crtl_PPF_multi.mat')

