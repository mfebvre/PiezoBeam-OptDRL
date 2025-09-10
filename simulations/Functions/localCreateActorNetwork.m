function actorNetwork = localCreateActorNetwork(ObsInfo,ActInfo,nNN)

NumHiddenUnitA = nNN;
DltInputDimension= prod(ObsInfo.Dimension);
numAct= prod(ActInfo.Dimension);
inputGraph=[featureInputLayer(DltInputDimension, 'Name', 'input_1'),...
                    fullyConnectedLayer(NumHiddenUnitA, 'Name', 'fc_1','WeightsInitializer','he','BiasInitializer','zeros'),...
                    reluLayer('Name','body_output1'),...
                    fullyConnectedLayer(NumHiddenUnitA, 'Name', 'fc_2','WeightsInitializer','he','BiasInitializer','zeros'),...
                    reluLayer('Name','body_output')]; %reluLayer('Name','relu_body'),...
                                                      %fullyConnectedLayer(NumHiddenUnitA, 'Name', 'fc_2'), ... 
                    
        
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
            fullyConnectedLayer(numAct, 'Name', 'fc_std');
            softplusLayer('Name', 'std');
            ];
    
    
actornet_default = layerGraph(inputGraph);
actornet_default = addLayers(actornet_default, meanPath);
actornet_default = addLayers(actornet_default, stdPath);
actornet_default = connectLayers(actornet_default,'body_output','fc_mean');
actornet_default = connectLayers(actornet_default,'body_output','fc_std');
actorNetwork=actornet_default;
end 