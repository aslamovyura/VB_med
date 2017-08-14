function features = timeDomainFeatures (segments, config)

%% ________________________ Set intervals  _____________________________ %%
    intervals.rr = segments.rr;
    intervals.s1 = segments.s1;
    intervals.s2 = segments.s2;
    intervals.systole = segments.systole;
    intervals.diastole = segments.diastole;

%% ______________ Set intervals lengthes as features ___________________ %%

    % The RR intervals lengthes
    for i = 1:length(intervals.rr)
        features.timeDomain.intervals.RR = length(intervals.rr{i});
    end
    
    % The S1 intervals lengthes
    for i = 1:length(intervals.s1)
        features.timeDomain.intervals.S1 = length(intervals.s1{i});
    end
    
    % The S2 intervals lengthes
    for i = 1:length(intervals.s2)
        features.timeDomain.intervals.S2 = length(intervals.s2{i});
    end
    
    % The systole intervals lengthes
    for i = 1:length(intervals.systole)
        features.timeDomain.intervals.systole = length(intervals.systole{i});
    end
   
    % The diastole intervals lengthes
    for i = 1:length(intervals.diastole)
        features.timeDomain.intervals.diastole = length(intervals.diastole{i});
    end

%% _____________ Calculating other features ____________________________ %%

    %Interval ratios
    for i = 1:length(intervals.systole)
        systToDiastRatio{i} = length(intervals.systole{i})/length(intervals.diastole{i});
    end
    features.timeDomain.intervalRatios.systToDiast = systToDiastRatio;
	
    for i = 1:length(intervals.systole)
        systToRRRatio{i} = length(intervals.systole{i})/length(intervals.rr{i});
    end
    features.timeDomain.intervalRatios.systToRR = systToRRRatio;
	
    for i = 1:length(intervals.diastole)
        diastToRRRatio{i} = length(intervals.diastole{i})/length(intervals.rr{i});
    end
    features.timeDomain.intervalRatios.diastToRR = diastToRRRatio;
    
    %Mean amplitude ratios, kurtosis and skewness
    %S1 mean amplitude and kurtosis
    for i = 1:length(intervals.s1)
        meanAmplitudeS1(i) = mean(abs(intervals.s1{i}));
        kurtosisS1(i) = kurtosis(intervals.s1{i});
        skewnessS1(i) = skewness(intervals.s1{i});
    end
	
    %S2 mean amplitude, kurtosis and skewness
    for i = 1:length(intervals.s2)
        meanAmplitudeS2(i) = mean(abs(intervals.s2{i}));
        kurtosisS2(i) = kurtosis(intervals.s2{i});
        skewnessS2(i) = skewness(intervals.s2{i});
    end
	
    %Systole mean amplitude, kurtosis and skewness
    for i = 1:length(intervals.systole)
        meanAmplitudeSystole(i) = mean(abs(intervals.systole{i}));
        kurtosisSystole(i) = kurtosis(intervals.systole{i});
        skewnessSystole(i) = skewness(intervals.systole{i});
    end
	
    %Diastole mean amplitude, kurtosis and skewness
    for i = 1:length(intervals.diastole)
        meanAmplitudeDiastole(i) = mean(abs(intervals.diastole{i}));
        kurtosisDiastole(i) = kurtosis(intervals.diastole{i});
        skewnessDiastole(i) = skewness(intervals.diastole{i});
    end
	
    %Amplitudes ration calculation
    features.timeDomain.amplitudesRatio.systToS1 = meanAmplitudeSystole./meanAmplitudeS1;
    features.timeDomain.amplitudesRatio.diastToS2 = meanAmplitudeDiastole./meanAmplitudeS2; 
    
    %Kurtosis
    features.timeDomain.kurtosis.s1 = kurtosisS1;
    features.timeDomain.kurtosis.s2 = kurtosisS2;
    features.timeDomain.kurtosis.systole = kurtosisSystole;
    features.timeDomain.kurtosis.diastole = kurtosisDiastole;
    
    %Skewness
    features.timeDomain.skewness.s1 = skewnessS1;
    features.timeDomain.skewness.s2 = skewnessS2;
    features.timeDomain.skewness.systole = skewnessSystole;
    features.timeDomain.skewness.diastole = skewnessDiastole;
    
end