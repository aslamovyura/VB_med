function features = timeDomainFeatures(segments, config)
%This function gets nad calculates time-domain features for signal
% Developer : A. Bourak
% Date :      27/07/2017
% Modified:   A. Bourak 14/08/2017
    heartStatesFields = fieldnames(segments);
    for i = 1:numel(heartStatesFields)
        curHeartStateField = segments.(heartStatesFields{i});
        curHeartStateFieldSize = size(curHeartStateField, 2);
        for j=1:curHeartStateFieldSize
            %Intercal length 
            if str2double(config.timeDomain.intervalLengthes)
                intervalLengthes{j} = length(curHeartStateField{j});
            end
            
            %Mean ampllitude of each state for next calculating
            if str2double(config.timeDomain.meanAmplitudesRatios)
                meanAmplitudes{j} = mean(abs(curHeartStateField{j}));
            end
            
            %kurtosis of each state
            if str2double(config.timeDomain.kurtosis)
                currKurtosis{j} = kurtosis(curHeartStateField{j});
            end
            
            %skewness of each state
            if str2double(config.timeDomain.skewness)
                currSkewness{j} = skewness(curHeartStateField{j});
            end
        end
    curHeartStateTitle = heartStatesFields{i};
    eval(strcat('features.timeDomain.intervals.', curHeartStateTitle,'=intervalLengthes;'));
    eval(strcat('features.timeDomain.kurtosis.', curHeartStateTitle,'=currKurtosis;'));
    eval(strcat('features.timeDomain.skewness.', curHeartStateTitle,'=currSkewness;'));
    eval(strcat('meanAmplitude.', curHeartStateTitle,'=meanAmplitudes;'));
    end
    
    
    if str2double(config.timeDomain.intervalRatios)
        for i = 1:length(segments.systole)
            features.timeDomain.intervalRatios.systToDiast {i} = length(segments.systole{i})/length(segments.diastole{i});
        end
	
        for i = 1:length(segments.systole)
            features.timeDomain.intervalRatios.systToRR{i} = length(segments.systole{i})/length(segments.rr{i});
        end
         
        for i = 1:length(segments.diastole)
            features.timeDomain.intervalRatios.diastToRR{i} = length(segments.diastole{i})/length(segments.rr{i});
        end
    end
    
    if str2double(config.timeDomain.meanAmplitudesRatios)
        features.timeDomain.amplitudesRatio.systToS1 = cell2mat(meanAmplitude.systole)./cell2mat(meanAmplitude.s1);
        features.timeDomain.amplitudesRatio.diastToS2 = cell2mat(meanAmplitude.diastole)./cell2mat(meanAmplitude.s2);
    end
    
    
end