clc
clear all
close all

load_files=["Data/raw/rec1_065.mat";
            "Data/raw/rec1_066.mat";
            "Data/raw/rec1_067.mat"];

for i=1:3

    S=importdata(load_files(i));    
    x_wn=S.X.Data;
    Fs=10000;

    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/Acc1'))));
    Acc1=S.Y(Index).Data;
    
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/Acc2'))));
    Acc2=S.Y(Index).Data;
    
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/Acc3'))));
    Acc3=S.Y(Index).Data;
            
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/VP1'))));
    Vp{1}=S.Y(Index).Data;    
        
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/VP2'))));
    Vp{2}=S.Y(Index).Data;
        
    Index = find(not(cellfun('isempty',strfind(string({S.Y.Path}),'Model Root/VP3'))));
    Vp{3}=S.Y(Index).Data;
      
        
    [~,I]=find(x_wn>30,1,'first');

    time_mes(i,:)=x_wn(1:I);
    Y{1,i}=detrend(Acc1(1:I));
    Y{2,i}=detrend(Acc2(1:I));
    Y{3,i}=detrend(Acc3(1:I));
    V(i,:)=detrend(Vp{i}(1:I));

end

time=[0:1:length(time_mes(1,:))-1]*1/10000;

I=length(time_mes(1,:));
for k=1:3
    for j=1:3
        Yd{j,k}=interp1(time, Y{j,k},time_mes(j,:));
        Vd(k,:)=interp1(time, V(k,:),time_mes(j,:));
        I_test=find(isnan(Yd{j,k}),1,'first');
        if I>I_test
            I=I_test-1;
        end
    end
end

for k=1:3
        for j=1:3
             
            [txy(j,k,:),f] = tfestimate(V(k,:),Y{j,k},[],[],[],Fs);
            FRF_mesure(j,k) = frd(txy(j,k,:),f*2*pi);
            [cs{j,k},fs{j,k}] = mscohere(V(k,:),Y{j,k},[],[],[],Fs);
        end 
end
                       
Y_c=[Yd{1,1}(1:I)+Yd{1,2}(1:I)+Yd{1,3}(1:I);
     Yd{2,1}(1:I)+Yd{2,2}(1:I)+Yd{2,3}(1:I);
     Yd{3,1}(1:I)+Yd{3,2}(1:I)+Yd{3,3}(1:I)];

save('Data/processed/data_extracted_from_measurement_for_id.mat')