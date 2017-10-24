function result = diastoleKurtosis(segment, config, info)
    for i = 1:size(segment.diastole, 2)
        result(i) = kurtosis(segment.diastole{i});
    end
%     result = mean(result);
    result = median(result);
end