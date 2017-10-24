function result = tr_obs_s1PowerSpectrum(segment, config, info, Fs)
    frequencyBands = [25 45 65 85 105 125 150 200 300 400];
    numOfFreqs = length(frequencyBands);
    Fs = 1000;
    for i = 1:size(segment.s1, 2)
        currSegment = cell2mat(segment.s1(i));
        windowLength = length(currSegment);
        hammingWindow = hamming(windowLength);
        curSegmentWindowed = currSegment.*hammingWindow;
        spectralDensity = fft(curSegmentWindowed, windowLength);

        powerSpectrum = ((abs(spectralDensity).^2))/(windowLength^2);

        powerSpectrum = powerSpectrum(1:windowLength/2+1);
        powerSpectrum(2:end-1) = 2*powerSpectrum(2:end-1);

        f = Fs*(0:(windowLength/2))/windowLength;
        for k=1:numOfFreqs-1
            lowerBound = frequencyBands(k);
            upperBound = frequencyBands(k+1);

            % find needed frequency band in power spectrum
            indices = find(f>=lowerBound & f<=upperBound);
            neededBand = powerSpectrum(indices);

            % find median power
            medianPowerAcrossBands(k) = median(neededBand);

        end
        result = mean(medianPowerAcrossBands);
        
    end
    
end