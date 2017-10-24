function result = segmentKurtosis (segment, config, info)
    heartStatesFields = fieldnames(segment);
    for i = 1:numel(heartStatesFields)
        curHeartStateField = segment.(heartStatesFields{i});
        curHeartStateFieldSize = size(curHeartStateField, 2);
        for j=1:curHeartStateFieldSize
            result(i, j) = kurtosis(curHeartStateField{j});
        end
    end
end