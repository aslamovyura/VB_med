function result = s2Kurtosis(segment, config, info)
    for i = 1:size(segment.s2, 2)
        result(i) = kurtosis(segment.s2{i});
    end
%     result = mean(result);
    result = median(result);

end