function result = s1Kurtosis(segment, config, info)
    for i = 1:size(segment.s1, 2)
        result(i) = kurtosis(segment.s1{i});
    end
%     result = mean(result);
    result = median(result);

end