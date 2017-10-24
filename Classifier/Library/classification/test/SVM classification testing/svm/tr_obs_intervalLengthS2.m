function result = intervalLengthS2(segment, config, info)
    for i = 1:size(segment.s2, 2)
        result(i) = length(segment.s2{i});
    end
%     result = mean(result);
    result = median(result);

end