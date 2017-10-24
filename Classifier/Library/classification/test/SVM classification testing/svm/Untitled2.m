for i = 1:size(bd_test, 1)
    k = 1;
    for j = 1:size(bd_test_segments, 2)
        
        if strcmp(bd_test(i).filename, bd_test_segments(j).filename) == 1
            currSignal(k).class = bd_test_segments(j).class;
            k = k + 1;
        end
    end
%     currSignal = cell2mat(currSignal');
    compareString = 'Normal';
    normalElements = 0;
    abnormalElements = 0;
    for k = 1:length(currSignal)
        if strcmp(currSignal(k).class, compareString)
            currSignal(k).class = 1;
            normalElements = normalElements + 1;
        else
            currSignal(k).class = 0;
            abnormalElements = abnormalElements + 1;
        end
    end
    if normalElements > abnormalElements
        signalClass = 'Normal';
    else
        signalClass = 'Abnormal';
    end
    result(i).filename = bd_test(i).filename;
    result(i).class = signalClass;
    clearvars currSignal signalClass ;
end