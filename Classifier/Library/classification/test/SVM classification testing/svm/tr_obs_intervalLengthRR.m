function result = intervalLengthRR(segment, config, info)
    for i = 1:size(segment.rr, 2)
        result(i) = length(segment.rr{i});
    end
%     result = mean(result);
    result = median(result);

end