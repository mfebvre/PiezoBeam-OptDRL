tStart = cputime;
clear all
close all


load('Data/processed/data_extracted_from_measurement_for_id.mat','Y','Y_c','V','time','Fs','FRF_mesure');

for k=1:3
        for j=1:3
             
            [txy(j,k,:),f] = tfestimate(V(k,:),Y{j,k},[],[],[],Fs);
            I1=find(f>5,1,'first');%En Hz %10
            I2=find(f>1000,1,'first');%En Hz %1100
            
            SYSG(j,k) = frd(txy(j,k,(I1:I2)),f(I1:I2)*2*pi);
        end 
end

opt = tfestOptions('EnforceStability', true);

%%
sys_tf_ref = tfest(SYSG,12,opt); 

bopts= bodeoptions;
bopts.FreqUnits='Hz';
bopts.FreqScale='linear';
bopts.PhaseWrapping='on';
bopts.XLim={[0,1600]};

FRF_mesure.InputName={'Pa1','Pa2','Pa3'};
FRF_mesure.OutputName={'Ps1','Ps2','Ps3'};

sys_tf=sys_tf_ref;
for i=1
    for j=2
        [z,p,k]=tf2zp(sys_tf_ref.Numerator{i, j},sys_tf_ref.Denominator{i, j});
        sys_tf_12 = tfest(SYSG(i,j),13,opt); 
        [z12,p12,k12]=tf2zp(sys_tf_12.Numerator,sys_tf_12.Denominator);
        [b,a] = zp2tf(z12,p12,k12);
        sys_tf.Numerator{i, j}=b;
        sys_tf.Denominator{i, j}=a;
    end
end

save('Data/processed/sys_id.mat',"sys_tf","FRF_mesure","SYSG","bopts")