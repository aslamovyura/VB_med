function [locsDenoisedSamples, locsResidualSamples] = waveletDenoising(file, config) 
% tic
% clc;
% clear all;
% close all;
% 
% %% ============= Set default parameters ================%%
% Root = fileparts(mfilename('fullpath'));
% cd(Root);
% 
% if ~exist(fullfile(pwd, 'Out'))
%     mkdir(fullfile(pwd, 'Out'));
% end

%deviceType - type of device used for getting signal
%deviceType = '1' - stethoscope
%deviceType = '2' - cellphone
% deviceType = '2';

%% ================== Set parameters =================================== %%
    minPeakDistance = str2double(config.waveletDenoising.minPeakDistance);
    minPeakHeight = str2double(config.waveletDenoising.minPeakHeight);
    printPlotsEnable = config.waveletDenoising.PrintPlotsEnable;
    detailedPlotsEnable = config.waveletDenoising.detailedPlotsEnable;
    wname = config.waveletDenoising.wname;
    deviceType = config.waveletDenoising.deviceType;
    decompositionLevels = str2double(config.waveletDenoising.level);
    
    if str2double(config.waveletDenoising.enable)
        signal = file.signal;
        Fs = file.Fs;
        if str2double(config.waveletDenoising.decimationEnable)
            decimateFactor = Fs/4000;
            signal = decimate(signal, decimateFactor);
            Fs = 4000;
        end

        %     %Using 1-st channel of signal
        signal = signal(:,1);
        signalLength = length(signal);    
    
        dt = 1/Fs;
        tmax = dt*signalLength;
        t = 0:dt:tmax-dt;

        %% ========================== Main Calculations =======================%%

        [waveletDenoiseSignal, decompositionFiltered, decompositionNonFiltered, coefficientsValidity ] = func_denoise_sw1d(signal, signalLength, Fs, deviceType, wname, decompositionLevels);
        waveletFilteredResidualSignal = signal - waveletDenoiseSignal';
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
                    [meanPeriodicityNonFiltered] = periodicityCalculation(decompositionNonFiltered(i,:), t, minPeakDistance, minPeakHeight, config);
                end

            end
        end

        % figure, plot(t, waveletFilteredResidualSignal);

        if str2double(printPlotsEnable)
            figure, findpeaks(waveletFilteredResidualSignal, Fs, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight);
            xlabel('Time (sec)');
            ylabel('Amplitude');
            title('Wavelet Filtered Residual Signal');
            fileName = 'Wavelet Filtered Residual Signal';
            fullFilePath = fullfile(pwd,'Out');
            fullFileName = fullfile(fullFilePath,fileName);
            print(fullFileName,'-djpeg91', '-r180');
            
            figure, findpeaks(waveletDenoiseSignal, Fs, 'MinPeakDistance', minPeakDistance, 'MinPeakHeight', minPeakHeight)
            xlabel('Time (sec)');
            ylabel('Amplitude');
            title(strcat('Wavelet denoise Signal, mean kurtosis = ', mat2str(meanKurtosisValueFiltered), ', min kurtosis = ', mat2str(minKurtosisValueFiltered)));
            fileName = strcat('Wavelet denoise Signal, mean kurtosis = ', mat2str(meanKurtosisValueFiltered), ', min kurtosis = ', mat2str(minKurtosisValueFiltered), '.jpg');
            fullFilePath = fullfile(pwd,'Out');
            fullFileName = fullfile(fullFilePath,fileName);
            print(fullFileName,'-djpeg91', '-r180');
            

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
        
        [meanPeriodicityResidualSignal, locsResidual] = periodicityCalculation(waveletFilteredResidualSignal, t, minPeakDistance, minPeakHeight, config);
        locsResidualSamples = int64(locsResidual*Fs + 1);

        [meanPeriodicityDenoisedSignal, locsDenoised] = periodicityCalculation(waveletDenoiseSignal, t, minPeakDistance, minPeakHeight, config);
        locsDenoisedSamples = int64(locsDenoised*Fs + 1);
        

        % toc
    end
end



