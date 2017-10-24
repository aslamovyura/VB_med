function [ bd_obs, maxSegmentsLength] = tre_fill_in_BD_signal( bd, segments, config, info )
% load('config.mat');
observations = config.observations.list;
% load('bd.mat');

% if config.parpoolEnable
%     parfor bi = 1:numel(bd)
%         [x, fs] = audioread(bd(bi).filename);
%         x_info = bd(bi);
%         x_info.fs = fs;
%         for oi = 1:numel(observations)
%             x_info.(observations{oi}) = feval(observations{oi}, x, config, x_info);
%         end
%         bd_obs{bi} = x_info;
%     end
% else
% %     nbi = 1;
% %     for bi = 1:numel(bd)
% %         [x, fs] = audioread(bd(bi).filename);
% %         channel = 1;
% %         if fs > 1000
% %             decimationFactor = fs/1000;
% %             fs = 1000;
% %             x = decimate(x, decimationFactor);
% %         end
% %         x = x(:, channel);
% % %         x = x(1:10*fs);
% %         
% % %         file.signal = x;
% %         Fs(bi) = fs;
% %         signals{bi, 1} = x;
% %     end
    
    
% %     maxSignal = signals{1};
% %     for i = 2:size(signals, 1)
% %         if length(signals{i}) > length(maxSignal)
% %             maxSignal = signals{i};
% %         end
% %     end
% %     
% %     for i = 1:size(signals, 1)
% %         lengthDifference = length(maxSignal) - length(signals{i});
% %         differenceMatrix = zeros(lengthDifference,1);
% %         finalSignal{i} = vertcat(signals{i}, differenceMatrix);
% % %          = finalSignal{i}
% %     end
    
% %     for bi = 1:numel(bd)
% %         file.signal = finalSignal{bi};
% %         file.Fs = Fs(bi);
% %         segments{bi} = springerMethod(file);
% %     end
    
% %     segments = cell2mat(segments);
% %     maxSegments = segments{1};
% %     for i = 2:size(segments, 2)
% %         if length(segments{i}.rr) > length(maxSegments.rr)
% %             maxSegments = segments{i};
% %         end
% %     end
% %     maxSegmentsLength = size(maxSegments.rr, 2);
% %     for i = 1:size(segments, 2)
% %         segmentsLengthDifference = length(maxSegments.rr) - length(segments(i).rr);
% %         segmentsDifferenceMatrix = cell(1,segmentsLengthDifference);
% %         for j = 1:size(segmentsDifferenceMatrix, 2)
% %             segmentsDifferenceMatrix{j} = zeros(1,80);
% %         end
% %         finalSegments{i}.rr = [segments(i).rr segmentsDifferenceMatrix];
% %         finalSegments{i}.s1 = [segments(i).s1 segmentsDifferenceMatrix];
% %         finalSegments{i}.s2 = [segments(i).s2 segmentsDifferenceMatrix];
% %         finalSegments{i}.systole = [segments(i).systole segmentsDifferenceMatrix];
% %         finalSegments{i}.diastole = [segments(i).diastole segmentsDifferenceMatrix];
% % %          = finalSignal{i}
% %     end
    for bi =1:numel(bd)
            x_info = bd(bi);
%             x_info.fs = bd(bi).fs;
            x_new = [];
            x_new.rr = segments{bi}.rr;
            x_new.s1 = segments{bi}.s1;
            x_new.s2 = segments{bi}.s2;
            x_new.systole = segments{bi}.systole;
            x_new.diastole = segments{bi}.diastole;
            for oi = 1:numel(observations)
                x_info.(observations{oi}) = feval(observations{oi}, x_new, config, x_info);
            end
        bd_obs{bi} = x_info;
% %         nbi = nbi +1;
    end
% end
    bd_obs = cell2mat(bd_obs);

%% Create classifier observations
switch config.observations.combining
	case 'all combinations'
		for bi = 1:numel(bd_obs)
			cur_obs = bd_obs(bi);

			obs_perm = cellfun(@(o) 1:size(cur_obs.(o),1), observations, 'UniformOutput',false);
			obs_ind = cell(size(obs_perm));
			[obs_ind{:}] = ndgrid(obs_perm{:});
			obs_ind = cell2mat(cellfun(@(x) x(:), obs_ind, 'UniformOutput',false));
			obs_ind = mat2cell(obs_ind, ones(size(obs_ind,1),1), size(obs_ind,2));

			class_obs = cell(size(obs_ind));
			for ii = 1:numel(obs_ind)
				class_obs{ii} = cell2mat(cellfun(@(o,ri) cur_obs.(o)(ri,:), observations, num2cell(obs_ind{ii}), 'UniformOutput',false));
			end
			bd_obs(bi).class_obs = cell2mat(class_obs);
		end
		
	case 'median'
		for bi = 1:numel(bd_obs)
			bd_obs(bi).class_obs = cell2mat(cellfun(@(o) median(bd_obs(bi).(o),1), observations, 'UniformOutput',false));
		end

	otherwise
		error('vbr:obs:comb','Uniknown observations combining method.');
end

