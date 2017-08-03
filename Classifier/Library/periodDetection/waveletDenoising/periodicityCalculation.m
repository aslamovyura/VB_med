function [meanPeriodicity, locs, meanPeriodicityNew] = periodicityCalculation(signal, t, minPeakDistance, minPeakHeight, config)

%% ======================== DESCRIPTION ================================ %%

% signal - signal in which periodicity need to be found
% t - time vector
% minPeakDistance - minimal distance between peaks for findpeks function
% minPeakHeight - minimal peak height for findpeaks function

%% ======================== MAIN CALCULATIONS ========================== %%
    if nargin < 4
        disp('Not enough input arguments');
        return;
    end
    meanPeriodicity = [];
    meanPeriodicityNew = [];
    locs = [];
    
    if str2double(config.waveletDenoising.periodicityCalculation.processingEnable)
        [~, locs] = findpeaks(signal, t, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight);
        summaryPeriodicity = 0;
        for i = 1:length(locs)-1
            periodicityHigh = locs(i+1);
            periodicityLow = locs(i);
            periodicityTemp(i) = periodicityHigh - periodicityLow;
            summaryPeriodicity = summaryPeriodicity + periodicityTemp(i);
            if i == 1
                j(i) = 0;   
            else
                j(i) = j(i-1)+1;
            end
        end
        meanPeriodicity = summaryPeriodicity / (length(periodicityTemp));
        for i = 1:length(periodicityTemp)
            if periodicityTemp(i) > 1.5*meanPeriodicity || periodicityTemp(i) < 0.5*meanPeriodicity
                periodicityTemp(i) = 0;
            end
        end
        if nnz(periodicityTemp) ~= numel(periodicityTemp)
            meanPeriodicityNew = sum(periodicityTemp)/nnz(periodicityTemp);
        end
        if str2double(config.waveletDenoising.periodicityCalculation.plotEnable)
            figure, plot(j, periodicityTemp, 'b')
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
        return;
    end
end