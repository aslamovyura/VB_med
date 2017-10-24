function result = meanAmplitudeRatioSysToS1(segment, config, info)
%     for i = 1:size(segment.systole, 2)
%         meanAmplitudeSys(i) = mean(abs(cell2mat(segment.systole)));
%         meanAmplitudeS1(i) = mean(abs(cell2mat(segment.s1)));
%     end
%     
%     sysToS1 = meanAmplitudeSys./meanAmplitudeS1;

    for i = 1:size(segment.systole, 2)
        result(i) = max(cell2mat(segment.systole(i)))/max(cell2mat(segment.s1(i)));
    end
    
%     result = mean(result);

    result = median(result);

    
end