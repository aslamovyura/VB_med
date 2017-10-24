function result = intervalLengthSystole(segment, config, info)
    for i = 1:size(segment.systole, 2)
        result(i) = length(segment.systole{i});
    end
%     result = mean(result);
    result = median(result);

end