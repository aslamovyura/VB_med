function [meanPeriodicity, locs, meanPeriodicityNew, allPeriodicities, excludedPeriodicities] = periodicityCalculation(signal, file, config)

% _________________________ DESCRIPTION _________________________________ %
%This function calculates of all valid periodicities using peakfinder

% Inputs:
% signal - analyzed signal;
% file - contains Fs;
% config - contains minPeakDistance, minPeakHeight and parametrs;

% Outputs:
% meanPeriodicity - mean periodicity of the signal;
% meanPeriodicityNew - mean periodicity of the signal if there were some unvalid periodicities
% allPeriodicities - list of all periodicities (valid and unvalid) in the signal;
% excludedPeriodicities - unvalid periodicities;
% locs - locations of the valid peaks on which calculates periodicities;

% Developer : A. Bourak
% Date :      04/08/2017
% Modified:   A. Bourak 11/08/2017

%% ________________________ Set default parameters _____________________ %%
Fs = file.Fs;
minPeakDistance = str2double(config.waveletDenoising.minPeakDistance);
minPeakHeight = str2double(config.waveletDenoising.minPeakHeight);

signalLength = length(signal);
dt = 1/Fs;
tmax = dt*signalLength;
t = 0:dt:tmax-dt;
%% ________________________ MAIN CALCULATIONS __________________________ %%
    if nargin < 3
        disp('Not enough input arguments');
        return;
    end
    meanPeriodicity = [];
    meanPeriodicityNew = [];
    locs = [];
    
    if str2double(config.waveletDenoising.periodicityCalculation.processingEnable)
        %Finding peaks on which will be calculated periodicity
        [~, locs] = findpeaks(signal, t, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight);
        summaryPeriodicity = 0;
        
        %Peaks validation
        locs = toneValidity(signal, t, config, locs);
        
        %Periodicities calculation
        for i = 1:length(locs)-1
            periodicityHigh = locs(i+1);
            periodicityLow = locs(i);
            allPeriodicities(i) = periodicityHigh - periodicityLow;
            summaryPeriodicity = summaryPeriodicity + allPeriodicities(i);
            if i == 1
                j(i) = 0;   
            else
                j(i) = j(i-1)+1;
            end
        end
        %Mean periodicity calculation 
        meanPeriodicity = summaryPeriodicity / (length(allPeriodicities));
        
        for i = 1:length(allPeriodicities)
            if allPeriodicities(i) > 1.2 || allPeriodicities(i) < 0.5
                excludedPeriodicities(i) = allPeriodicities(i);
                allPeriodicities(i) = 0;
            end
        end
        if ~exist('excludedPeriodicities', 'var')
            excludedPeriodicities = zeros(1, length(allPeriodicities));
        end
            
        if nnz(allPeriodicities) ~= numel(allPeriodicities)
            meanPeriodicityNew = sum(allPeriodicities)/nnz(allPeriodicities);
        end
        
        %Plot periodicities as graph
        if str2double(config.waveletDenoising.periodicityCalculation.plotsEnable)
            figure, plot(j, allPeriodicities, 'b')
            title('Periodicity values denoised signal');
            xlabel('Iteration');
            ylabel('Periodicity value');
            if ~exist('meanPeriodicityNew', 'var')
                leg = ['Mean Periodicity ' num2str(meanPeriodicity) ' sec'];
                legend(leg, 'Location', 'northeast');
            else
                leg = ['Mean Periodicity at the start ' num2str(meanPeriodicity, '%.4f')    ' sec';...
                       'Mean Periodicity at the end   '  num2str(meanPeriodicityNew, '%.4f') ' sec'];
                legend(leg, 'Location', 'northeast');
            end
        end
    else 
        return
    end
end