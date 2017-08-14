function [meanFramesTable, fullFramesTable] = framesExtraction(signal, file,  config, meanPeriodicity, allPeriodicities, excludedPeriodicities)
%This function is extracts frames from signal using mean periodicity of the
%signal and all periodicities

% Developer : A. Bourak
% Date :      27/07/2017
% Modified:   A. Bourak 11/08/2017


Fs = file.Fs;

signalLength = length(signal);
dt = 1/Fs;
tmax = dt*signalLength;
t = 0:dt:tmax-dt;

%Frames extraction by mean periodicities
numOfFrames = floor(max(t)/meanPeriodicity);
for i = 1:numOfFrames
    if i == 1
        startOfFrame(i) = 1;
    else
        startOfFrame(i) = round(endOfFrame(i-1) + 1);
    end
    endOfFrame(i) = round(startOfFrame(i) + meanPeriodicity*Fs);
    meanFramesTable{i} = signal(startOfFrame(i):endOfFrame(i));
end

%frames estimation by all periodicities
fullFramesTable = {};
numOfAllFrames = int64(length(allPeriodicities));
for i = 1:numOfAllFrames
    
    if i == 1
        startOfFrameFull(i) = 1;
    else
        startOfFrameFull(i) = endOfFrameFull(i-1) + 1;
    end
    if allPeriodicities(i) == 0
        allPeriodicities(i) = excludedPeriodicities(i);
    end
    endOfFrameFull(i) = startOfFrameFull(i) + allPeriodicities(i)*Fs;
    fullFramesTable{i} = signal(startOfFrameFull(i):endOfFrameFull(i));

end



end