function result = intervalLengthDiastole(segment, config, info)
    for i = 1:size(segment.diastole, 2)
        result(i) = length(segment.diastole{i});
    end
%     result = mean(result);
    result = median(result);

end