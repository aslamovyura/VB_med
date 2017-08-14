function [KMean, KMin, validityFlag] = windowKurtosis (signal, Fs) % revise changing input parameters to "file" structure
% This function calculates kurtosis for signal divided 
% into windows with overlap and returns the following values:
% 'KMean' which contains the mean kurtosis value over all windows;
% 'KMin' - the least kurtosis value over all windows;
% 'validityFlag' indicates whether the signal is valid,
% i.e. whose mean kurtosis value is greater than "thresholdKurtosisLevel"
% (5 by default) and standard deviation of kurtosis values over all windows 
% is less than "thresholdSTDLevel" (15 by default).

% created by Ivan Trus

%% ___________________ DEFAULT_PARAMETERS _____________________________ %%

secPerFrame = 1;
secOverlapValue = 0.975;
thresholdKurtosisLevel = 5;
thresholdSTDLevel = 15;

%% ___________________ MAIN_CALCULATIONS ______________________________ %%

frame = secPerFrame*Fs;
overlap = secOverlapValue*Fs;
L = length ( signal );
increment = frame - overlap;      % distance beween start of window1 and start window2
position = 1;
i = 1;
KVector = zeros ( 1, floor(L * ( frame + overlap) / frame^2 ));  % memory allocation
while position < L - frame

    currentSignalChunk = signal ( position : position + frame );
    meanOfCurChunk = mean(currentSignalChunk);
    
    if meanOfCurChunk ~= 0
        KVector (i) = kurtosis(currentSignalChunk);
    else
        KVector (i) = 0;
    end
    
    position = position + increment;
    i = i + 1;
end

KMean = mean ( KVector ); % kurtosis vector mean value
KMin = min( KVector ); % kurtosis vector min value

if (KMean > thresholdKurtosisLevel && std(KVector) < thresholdSTDLevel)
    validityFlag = 1;
else
    validityFlag = 0;
end


end