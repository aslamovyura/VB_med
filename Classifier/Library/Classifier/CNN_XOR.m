clc;
clear all
close all

trainingSet = [0, 0;
               0, 1;
               1, 0;
               1, 1];
trainingResults = [0;
                   1;
                   1;
                   0];
maxSet = length (trainingSet);
maxEpoch = 1;
layer1 = [0.45, -0.12;
          0.78 , 0.13];
layerOut = [1.5, -2.3];

for i = 1:maxEpoch
    for j = 1:maxSet
            
        input = trainingSet(j, :);
        for k = 1:length(layer1)   % work with k-th neuron in layer
            
            in = 0;
            for l = 1:length(layer1(k, :))  % calculation for k-th neuron
                in = in + input(l)*layer1(k, l);
            end
            layer1Out(k) = sigmoid(in);  % k-th neuron output
        end
                
        layerOutOut(j) = sigmoid(sum(layerOut.*layer1Out)); % layerOut output calculation
        
        MSError = mse(layerOutOut(j), trainingResults(j));   
        
        % Backpropagation
%         deltaOut1 = (trainingResults(j) - layerOutOut(j))
        
        
        
    end
end


function sigm = sigmoid(x)
sigm = (1+exp(-x)).^-1;
end

function MSError = mse(result, ideal)
sum = 0;
n = length(result);
for z = 1:n
    sum = sum + (result(z) - ideal(z))^2;
end
MSError = sum / n;
end
