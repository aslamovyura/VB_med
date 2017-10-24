function result = meanAmplitudeRatioDiaToS2(segment, config, info)
%     for i = 1:size(segment.systole, 2)
%         meanAmplitudeDia(i) = mean(abs(cell2mat(segment.diastole)));
%         meanAmplitudeS2(i) = mean(abs(cell2mat(segment.s2)));
%     end
    
%     diaToS2 = meanAmplitudeDia./meanAmplitudeS2;
for i = 1:size(segment.diastole, 2)
    result(i) = max(cell2mat(segment.diastole(i)))/max(cell2mat(segment.s2(i)));
end
% result = mean(result);
    result = median(result);


end