function [peakLocations] = spectrumFiltration(file, config)
%% ___________________initialization________________________________%%
    Fs = file.Fs;
    signal = file.signal;
    signalLength = length(signal);
    dt = 1/Fs;
    tmax = dt*signalLength;
    t = 0:dt:tmax-dt;
    df = Fs/signalLength;
    f = 0:df:Fs-df;
    MinPeakHeight = str2double(config.config.parameters.evaluation.spectrumFiltration.Attributes.MinPeakHeight);
    TimePeakDistance = str2double(config.config.parameters.evaluation.spectrumFiltration.Attributes.TimePeakDistance);
    MinPeakDistance = TimePeakDistance / dt;   
    maxKurtosis = 0;
    
    filterBank = [5, 60; 10, 65; 15, 70; 20, 75; 25, 80; 30, 85; 35, 90; 40, 95; 45, 100];
        
    %% _________________calculation_____________________________________%%
    
	spectrum = fft(signal);

    if config.config.parameters.evaluation.spectrumFiltration.Attributes.DetailedPlotEnable
       figure;
       plot(f,spectrum);
       title('Signal spectrum'), xlabel('Frequency (Hz)'), ylabel('Amplitude');
    end

    for i =1:length(filterBank(:,1))
        
        lowFrequency = filterBank(i,1);   %Frequency band for filtration
        highFrequency = filterBank(i,2);
    
        f_valid = (f > lowFrequency) & (f < highFrequency);
        spec_valid = spectrum;
        spec_valid(~f_valid) = 0;
        filteredSignal(i,:) = ifft(spec_valid,'symmetric');
        
        [~, locs] = findpeaks(filteredSignal(i, :), 'MinPeakHeight',MinPeakHeight,'MinPeakDistance',MinPeakDistance);
    
        [kMean, kMin, ~] = windowKurtosis(filteredSignal(i,:), Fs);
        periods = diff(locs) * dt;
        meanPeriod = mean(periods);
    
        if config.config.parameters.evaluation.spectrumFiltration.Attributes.DetailedPlotEnable
            figure;
            findpeaks(filteredSignal(i, :), t, 'MinPeakHeight',MinPeakHeight,'MinPeakDistance',TimePeakDistance);    
            title([ 'Spectrum filtered signal N ' num2str(i) ' in freq band: ' num2str(lowFrequency) ', ' num2str(highFrequency)]), xlabel('Time (Sec)'), ylabel('Amplitude');
            figure, plot(periods);
            title(['Mean Period' num2str(meanPeriod) ', kMean: ' num2str(kMean) ', kMin: ' num2str(kMin)]) , xlabel('periods(N)'), ylabel('Duration(s)');
        end
        
    if kMean >= maxKurtosis
        maxKurtosis = kMean;
        clear resultSignal, resultSignal = filteredSignal(i,:);
        clear peakLocations, peakLocations = locs;
        number = i;
    end    	   
    end
    if config.config.parameters.evaluation.spectrumFiltration.Attributes.plotEnable
        figure, plot( t, resultSignal, t(peakLocations), resultSignal(peakLocations), 'r*');
        title(['Spectrum filtration result N ' num2str(number) ' & peaks']) , xlabel('Time(s)'), ylabel('Amplitude(V)');
    end
    if config.config.parameters.evaluation.spectrumFiltration.Attributes.printPlotEnable
        fileName = 'Spectrum Filtered Signal';
        fullFilePath = fullfile(pwd,'Out');
        fullFileName = fullfile(fullFilePath,fileName);
        print(fullFileName,'-djpeg91', '-r180');
%     audiowrite(strcat('Out\specFiltered', num2str(i), '.wav'), filteredSignal, Fs);
    end
end
% 
% % Signal plotting & saving
% 
% if Parameters.printPlotsEnable
%     h = figure 
%     plot(t, signal, t(locations), signal(locations), '*r'), title('Signal');
%     xlabel('Time (Sec)');
%     ylabel('Amplitude');
%     
% end
% fileName = 'Original signal';
% fullFilePath = fullfile(pwd,'Out');
% fullFileName = fullfile(fullFilePath,fileName);
% print(fullFileName,'-djpeg91', '-r180');
% savefig(h, fullFileName, 'compact');
% 
% % Spectrogram
% % figure, spectrogram (signal);
