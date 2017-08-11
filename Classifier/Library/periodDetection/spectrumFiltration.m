function [peakLocations] = spectrumFiltration(file, parameters)
%% Function description:
% This function passes the signal through the filter bank. 
% Then choose the result with the biggest kurtosis and apply function 
% "findpeaks" to this variant. 
%% In: file.signal, file.Fs, parameters of the processing
%% Out: peakLocations - locations of the peaks(1st tone) in the original signal
%% ___________________initialization________________________________%%
    Fs = file.Fs;
    signal = file.signal;
    signalLength = length(signal);
    dt = 1/Fs;
    tmax = dt*signalLength;
    t = 0:dt:tmax-dt;
    df = Fs/signalLength;
    f = 0:df:Fs-df;
    minPeakHeight = str2double(parameters.minPeakHeight);
    timePeakDistance = str2double(parameters.timePeakDistance);
    minPeakDistance = timePeakDistance / dt;   
    maxKurtosis = 0;
    
    filterBank = [5, 60; 10, 65; 15, 70; 20, 75; 25, 80; 30, 85; 35, 90; 40, 95; 45, 100];
        
    %% _________________calculation_____________________________________%%
    
	spectrum = fft(signal);

    if str2double(parameters.detailedPlotEnable)
       figure;
       plot(f,spectrum);
       title('Signal spectrum'), xlabel('Frequency (Hz)'), ylabel('Amplitude');
    end

    for i =1:length(filterBank(:,1))
        
        lowFrequency = filterBank(i,1);   % Frequency band for filtration
        highFrequency = filterBank(i,2);
    
        f_valid = (f > lowFrequency) & (f < highFrequency);
        spec_valid = spectrum;
        spec_valid(~f_valid) = 0;       % Filtration in frequency band
        filteredSignal(i,:) = ifft(spec_valid,'symmetric'); 
        
        [~, locs] = findpeaks(filteredSignal(i, :), 'MinPeakHeight',minPeakHeight,'MinPeakDistance',minPeakDistance);  %Peak locations in filtered signal
    
        [kMean, kMin, ~] = windowKurtosis(filteredSignal(i,:), Fs); % Kurtosis calculation to find the best filtered variant
        periods = diff(locs) * dt;
        meanPeriod = mean(periods);
    
        if str2double(parameters.detailedPlotEnable)  % plotting filtered signals and their's periods
            figure;
            findpeaks(filteredSignal(i, :), t, 'MinPeakHeight',minPeakHeight,'MinPeakDistance',timePeakDistance);    
            title([ 'Spectrum filtered signal N ' num2str(i) ' in freq band: ' num2str(lowFrequency) ', ' num2str(highFrequency)]), xlabel('Time (Sec)'), ylabel('Amplitude');
            figure, plot(periods);
            title(['Mean Period' num2str(meanPeriod) ', kMean: ' num2str(kMean) ', kMin: ' num2str(kMin)]) , xlabel('periods(N)'), ylabel('Duration(s)');
        end
        
    if kMean >= maxKurtosis  % looking for the best filtered signal via kurtosis
        maxKurtosis = kMean;
        clear resultSignal, resultSignal = filteredSignal(i,:);
        clear peakLocations, peakLocations = locs;
        number = i;
    end    	   
    end
    if str2double(parameters.plotEnable)  % plotting peaks on the original signal
        figure, plot( t, resultSignal, t(peakLocations), resultSignal(peakLocations), 'r*');
        title(['Spectrum filtration result N ' num2str(number) ' & peaks']) , xlabel('Time(s)'), ylabel('Amplitude(V)');
    end
    if str2double(parameters.printPlotEnable)  % saving filtered signal
        fileName = 'Spectrum Filtered Signal';
        fullFilePath = fullfile(pwd,'Out');
        fullFileName = fullfile(fullFilePath,fileName);
        print(fullFileName,'-djpeg91', '-r180');
    end
end