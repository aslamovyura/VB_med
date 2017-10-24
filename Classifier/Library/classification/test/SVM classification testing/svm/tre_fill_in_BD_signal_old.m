function [ bd_obs] = tre_fill_in_BD_signal_old( bd, config, info )
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
    nbi = 1;
    for bi = 1:numel(bd)
        [x, fs] = audioread(bd(bi).filename);
        channel = 1;
        if fs > 1000
            decimationFactor = fs/1000;
            fs = 1000;
            x = decimate(x, decimationFactor);
        end
        x = x(:, channel);
%         signals{bi, 1} = x;
        file.signal = x;
        file.Fs = fs;
        segments = springerMethod(file);
        if size(segments.rr, 2) < 10
%             nbi = nbi - 1;
            continue;
        else
            x_info = bd(bi);
            x_info.fs = fs;
            x_new = [];
            x_new.rr = segments.rr(1:10);
            x_new.s1 = segments.s1(1:10);
            x_new.s2 = segments.s2(1:10);
            x_new.systole = segments.systole(1:10);
            x_new.diastole = segments.diastole(1:10);
            for oi = 1:numel(observations)
                x_info.(observations{oi}) = feval(observations{oi}, x_new, config, x_info);
            end

            
        end
        bd_obs{nbi} = x_info;
        nbi = nbi +1;
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

