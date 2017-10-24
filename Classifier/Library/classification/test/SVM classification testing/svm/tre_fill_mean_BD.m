function result = tre_fill_mean_BD(bd, bd_seg, config, info)
observations = config.observations.list;
    
        for i =1:numel(bd)
            result(i).filename = bd(i).filename;
            result(i).class = bd(i).class;
            k = 1;
            for oi = 1:numel(config.observations.list)
                for j = 1:numel(bd_seg)
                    if strcmp(bd(i).filename, bd_seg(j).filename) == 1
                            currObservation = observations{oi};
                            currSignalObservation(k) = bd_seg(j).(currObservation);
                            k = k + 1;
                    end
                end
                meanCurrObservation = mean(currSignalObservation);
                result(i).(currObservation) = meanCurrObservation;
            end
%             result(i) = bd(i);
            
           clearvars  currSignalObservation meanCurrObservation
            
        end