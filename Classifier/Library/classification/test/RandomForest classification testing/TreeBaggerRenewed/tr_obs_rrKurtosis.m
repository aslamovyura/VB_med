function result = rrKurtosis(segment, config, info)
    for i = 1:size(segment.rr, 2)
        result(i) = kurtosis(segment.rr{i});
    end
%     result = mean(result);
    result = median(result);

end