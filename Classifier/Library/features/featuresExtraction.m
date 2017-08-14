function features = featuresExtraction(segments, file, config)
    %time-domain features extraction
    timeFeatures = timeDomainFeatures(segments, config);
    %frequency-domain features extraction
    frequencyFeatures = frequencyDomainFeatures(segments, file, config);
    %write results to structure
    features.timeDomain = timeFeatures.timeDomain;
    features.frequencyDomain = frequencyFeatures.frequencyDomain;
end