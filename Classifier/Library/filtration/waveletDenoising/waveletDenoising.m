function result = waveletDenoising(file, config) 

% This function denoises signal using stationary wavelet transform (SWT)
% decomposition

% Developer : A. Bourak
% Date :      27/07/2017
% Modified:   A. Bourak 11/08/2017

%% ________________________ Set parameters _____________________________ %%
    minPeakDistance = str2double(config.waveletDenoising.minPeakDistance);
    minPeakHeight = str2double(config.waveletDenoising.minPeakHeight);
    plotsEnable = config.waveletDenoising.plotsEnable;
    printPlotsEnable = config.waveletDenoising.printPlotsEnable;
    detailedPlotsEnable = config.waveletDenoising.detailedPlotsEnable;
    

%%________________________ Main Calculations ____________________________%%    
    if str2double(config.waveletDenoising.enable)
        signal = file.signal;
        Fs = file.Fs;

        if size(signal, 1) < size(signal, 2)
            signal = signal';
        end
        
        signalLength = length(signal);    
    
        dt = 1/Fs;
        tmax = dt*signalLength;
        t = 0:dt:tmax-dt;
        
        %Calculating signaldecomposition using SWT
        [waveletDenoiseSignal, decompositionFiltered, decompositionNonFiltered, coefficientsValidity ] = func_denoise_sw1d(file, config);
        
        %Signal normalization
        waveletDenoiseSignalMaximum = max(waveletDenoiseSignal);
        waveletDenoiseSignal = waveletDenoiseSignal./waveletDenoiseSignalMaximum;
        
        %Calculating and normalization residual signal
        waveletFilteredResidualSignal = signal - waveletDenoiseSignal';
        waveletFilteredResidualSignalMaximum = max(waveletFilteredResidualSignal);
        waveletFilteredResidualSignal = waveletFilteredResidualSignal./waveletFilteredResidualSignalMaximum;
        
        %Calculating mean and min kurtosis values for original signal and
        %wavelet denoised signal
        [meanKurtosisValueFiltered, minKurtosisValueFiltered] = windowKurtosis(waveletDenoiseSignal, Fs);
        [signalMeanKurtosis, signalMinKurtosis] = windowKurtosis(signal, Fs);
  
        %Plot decomposition coefficients
        if str2double(detailedPlotsEnable)
            decompositionSize = size(decompositionFiltered);
            for i = 1:decompositionSize(1)-1
                [meanKurtosisValueFiltered, minKurtosisValueFiltered] = windowKurtosis(decompositionFiltered(i,:), Fs);
                figure, plot(t, decompositionFiltered(i, :));
                xlabel('Time (sec)');
                ylabel('Amplitude');
                title(strcat('Signal decomposition filtered_', mat2str(i), ', mean kurtosis=', mat2str(meanKurtosisValueFiltered),...
                             ', min kurtosis = ', mat2str(minKurtosisValueFiltered)));
                fileName = strcat('Signal decomposition filtered_', mat2str(i), ', mean kurtosis=', mat2str(meanKurtosisValueFiltered),...
                                  ', min kurtosis = ', mat2str(minKurtosisValueFiltered), '.jpg');
                fullFilePath = fullfile(pwd,'Out');
                fullFileName = fullfile(fullFilePath, fileName);
                print(fullFileName,'-djpeg91', '-r180');

                if coefficientsValidity(i) == 1
                    [meanPeriodicityNonFiltered] = periodicityCalculation(decompositionNonFiltered(i,:), t, minPeakDistance, minPeakHeight, config);
                end
            end


            decompositionSize = size(decompositionNonFiltered);
            for i = 1:decompositionSize(1)-1
                [meanKurtosisValueNonFiltered, minKurtosisValueNonFiltered] = windowKurtosis(decompositionNonFiltered(i,:), Fs);
                figure, plot(t, decompositionNonFiltered(i, :));
                xlabel('Time (sec)');
                ylabel('Amplitude');
                title(strcat('Signal decomposition non filtered_', mat2str(i), ', mena kurtosis=', mat2str(meanKurtosisValueNonFiltered),...
                             ', min kurtosis = ', mat2str(minKurtosisValueNonFiltered)));
                fileName = strcat('Signal decomposition non filtered_', mat2str(i), ', mean kurtosis=', mat2str(meanKurtosisValueNonFiltered),...
                                  ', min kurtosis = ', mat2str(minKurtosisValueNonFiltered), '.jpg');
                fullFilePath = fullfile(pwd,'Out');
                fullFileName = fullfile(fullFilePath, fileName);
                print(fullFileName,'-djpeg91', '-r180');

                if coefficientsValidity(i) == 1
                    meanPeriodicityNonFiltered = periodicityCalculation(decompositionNonFiltered(i,:), t, minPeakDistance, minPeakHeight, config);
                end

            end
        end

        %Plot wavelet denoised and residual signals with peaks 
        if str2double(plotsEnable)
            figure, findpeaks(waveletFilteredResidualSignal, Fs, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight);
            xlabel('Time (sec)');
            ylabel('Amplitude');
            title('Wavelet Filtered Residual Signal');
            if str2double(printPlotsEnable)
                fileName = 'Wavelet Filtered Residual Signal';
                fullFilePath = fullfile(pwd,'Out');
                fullFileName = fullfile(fullFilePath,fileName);
                print(fullFileName,'-djpeg91', '-r180');
            end
            
            figure, findpeaks(waveletDenoiseSignal, Fs, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight)
            xlabel('Time (sec)');
            ylabel('Amplitude');
%             title(strcat('Wavelet denoise Signal, mean kurtosis = ', mat2str(meanKurtosisValueFiltered), ', min kurtosis = ', mat2str(minKurtosisValueFiltered)));
            title('Wavelet denoise Signal');
            if str2double(printPlotsEnable)
                fileName = 'Wavelet denoise Signal';
                fullFilePath = fullfile(pwd,'Out');
                fullFileName = fullfile(fullFilePath,fileName);
                print(fullFileName,'-djpeg91', '-r180');
            end
            

%             figure, plot(t,signal, 'b', t (locsDenoisedSamples'), signal(locsDenoisedSamples'), 'r*'); 
%             title(strcat('Signal, mean kurtosis = ', mat2str(signalMeanKurtosis), ', min kurtosis = ', mat2str(signalMinKurtosis)))
%             xlabel('Time (Sec)');
%             ylabel('Signal');
%             hold on;
%             fileName = strcat('Original signal, mean kurtosis = ', mat2str(signalMeanKurtosis), ', min kurtosis =  ', mat2str(signalMinKurtosis), '.jpg');
%             fullFilePath = fullfile(pwd,'Out');
%             fullFileName = fullfile(fullFilePath,fileName);
%             print(fullFileName,'-djpeg91', '-r180');

%             h = figure 
%             plot(t,signal, 'b', t (locsResidualSamples'), signal(locsResidualSamples'), 'r*'); 
%             title(strcat('Signal, mean kurtosis = ', mat2str(signalMeanKurtosis), ', min kurtosis = ', mat2str(signalMinKurtosis)))
%             xlabel('Time (Sec)');
%             ylabel('Signal');
%             hold on;
%             fileName = strcat('Original signal, mean kurtosis = ', mat2str(signalMeanKurtosis), ', min kurtosis =  ', mat2str(signalMinKurtosis), '.jpg');
%             fullFilePath = fullfile(pwd,'Out');
%             fullFileName = fullfile(fullFilePath,fileName);
%             print(fullFileName,'-djpeg91', '-r180');
        end
        
        %Calculating periodicity of the residual signal
        [meanPeriodicityResidualSignal, locsResidual, ~, residualSignalAllPeriodicities, residualSignalExcludedPeriodicities] = periodicityCalculation(waveletFilteredResidualSignal, file, config);
        locsResidualSamples = int64(locsResidual*Fs + 1);
        %Extraction of the frames in the residual signal using periodicity
        [residualSignalMeanFramesTable, residualSignalFullFramesTable] = framesExtraction(signal, file, config, meanPeriodicityResidualSignal, residualSignalAllPeriodicities, residualSignalExcludedPeriodicities);

        %Calculating periodicity of the wavelet denoised signal
        [meanPeriodicityDenoisedSignal, locsDenoised, ~, denoisedSignalAllPeriodicities, denoisedSignalExcludedPeriodicities] = periodicityCalculation(waveletDenoiseSignal, file, config);
        locsDenoisedSamples = int64(locsDenoised*Fs + 1);
        %Extraction of the frames in the wavelet denoised signal using periodicity
        [denoisedSignalMeanFramesTable, denoisedSignalFullFramesTable] = framesExtraction(signal, file, config, meanPeriodicityResidualSignal, denoisedSignalAllPeriodicities, denoisedSignalExcludedPeriodicities);
        
        %Write results to structure
        result.residualSignal.meanPeriodicity = meanPeriodicityResidualSignal;
        result.residualSignal.locsSamples = locsResidualSamples;
        result.residualSignal.meanFramesTable = residualSignalMeanFramesTable;
        result.residualSignal.fullFramesTable = residualSignalFullFramesTable;
        
        result.denoisedSignal.meanPeriodicity = meanPeriodicityDenoisedSignal;
        result.denoisedSignal.locsSamples = locsDenoisedSamples;
        result.denoisedSignal.meanFramesTable = denoisedSignalMeanFramesTable;
        result.denoisedSignal.fullFramesTable = denoisedSignalFullFramesTable;
        
        % toc
    end
end



