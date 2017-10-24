function base_obs = vbr_process_observations(base, config)
%vbr_process_observations Calculate observations from the vibration base files.

%% Calculate every file observations
observations = config.observations.list;
base_obs = cell(size(base));
if config.parpoolEnable
    parfor bi = 1:numel(base)
        [x, fs] = audioread(base(bi).filename);
        x_info = base(bi);
        x_info.fs = fs;
        for oi = 1:numel(observations)
            x_info.(observations{oi}) = feval(observations{oi}, x, config, x_info);
        end
        base_obs{bi} = x_info;
    end
else
    for bi = 1:numel(base)
        [x, fs] = audioread(base(bi).filename);
        channel = 1;
        x = x(:, channel);
        x_info = base(bi);
        x_info.fs = fs;
        for oi = 1:numel(observations)
            x_info.(observations{oi}) = feval(observations{oi}, x, config, x_info);
        end
        base_obs{bi} = x_info;
    end
end
    
    
base_obs = cell2mat(base_obs);

%% Create classifier observations
switch config.observations.combining
	case 'all combinations'
		for bi = 1:numel(base_obs)
			cur_obs = base_obs(bi);

			obs_perm = cellfun(@(o) 1:size(cur_obs.(o),1), observations, 'UniformOutput',false);
			obs_ind = cell(size(obs_perm));
			[obs_ind{:}] = ndgrid(obs_perm{:});
			obs_ind = cell2mat(cellfun(@(x) x(:), obs_ind, 'UniformOutput',false));
			obs_ind = mat2cell(obs_ind, ones(size(obs_ind,1),1), size(obs_ind,2));

			class_obs = cell(size(obs_ind));
			for ii = 1:numel(obs_ind)
				class_obs{ii} = cell2mat(cellfun(@(o,ri) cur_obs.(o)(ri,:), observations, num2cell(obs_ind{ii}), 'UniformOutput',false));
			end
			base_obs(bi).class_obs = cell2mat(class_obs);
		end
		
	case 'median'
		for bi = 1:numel(base_obs)
			base_obs(bi).class_obs = cell2mat(cellfun(@(o) median(base_obs(bi).(o),1), observations, 'UniformOutput',false));
		end

	otherwise
		error('vbr:obs:comb','Uniknown observations combining method.');
end
