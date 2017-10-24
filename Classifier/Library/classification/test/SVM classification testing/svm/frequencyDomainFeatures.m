function features = frequencyDomainFeatures(segments, file, config)
    if str2double(config.frequencyDomain.powerSpectrum)
        
        %% Power Spectrum
        Fs = file.Fs;

        frequencyBands = [25 45 65 85 105 125 150 200 300 400];
        numOfFreqs = length(frequencyBands);

        % iterate through the struct to retrieve all segments
        heartStatesFields = fieldnames(segments);

        for i = 1:numel(heartStatesFields)

            curHeartStateField = segments.(heartStatesFields{i});
            curHeartStateFieldSize = size(curHeartStateField, 2);

            % matrix containing median values across bands, where columns
            % correspond to frequency bands and rows - to heart cycles
            medianPowerAcrossBands = zeros(curHeartStateFieldSize,numOfFreqs-1);

            for j=1:curHeartStateFieldSize

                curSegment = curHeartStateField{j}';

                windowLength = length(curSegment);
                hammingWindow = hamming(windowLength);

                curSegmentWindowed = curSegment.*hammingWindow;
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
                    medianPowerAcrossBands(j,k) = median(neededBand);

                end
            end

            % mean of median power of all cycles
            meanOfMedianPower = mean(medianPowerAcrossBands);

            % saving results into struct
            curHeartStateTitle = heartStatesFields{i};
            eval(strcat('features.frequencyDomain.powerSpectrum.',...
                        curHeartStateTitle,'=meanOfMedianPower;'));
        end
    end
end









