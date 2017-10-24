function [segments, bd] = tre_segments_extraction_signal(bd, config, info)

    for bi = 1:numel(bd)
        %Reading signals from BD
        [x, fs] = audioread(bd(bi).filename);
        
        channel = 1;
        if fs > 1000
            decimationFactor = fs/1000;
            fs = 1000;
            x = decimate(x, decimationFactor);
        end
        bd(bi).fs = fs;
        x = x(:, channel);
        Fs(bi) = fs;
        signals{bi, 1} = x;
        file.signal = x;
        file.Fs = fs;
        segments{bi} = springerMethod(file);
    end
    
    
    
%     segments = cell2mat(segments);