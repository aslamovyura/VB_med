function result = intervalLengthS1(segment, config, info)
    for i = 1:size(segment.s1, 2)
        result(i) = length(segment.s1{i});
    end
%     result = mean(result);
    result = median(result);

end