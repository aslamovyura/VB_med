function bd = tre_fill_bd_to_full_size (bd, config, info)
    observations = config.observations.list;
    
    for oi = 1:numel(observations)
        currObservation = observations{oi};
        maxLength = length(bd(1).(currObservation));
        for bi = 2:numel(bd)
            if length(bd(bi).(currObservation)) > maxLength
                maxLength = length(bd(bi).(currObservation));
            end
        end
        for bi = 1:numel(bd)
            if length(bd(bi).(currObservation)) < maxLength
                difference = maxLength - length(bd(bi).(currObservation));
                diffVector = zeros(1, difference);
                bd(bi).(currObservation) = [bd(bi).(currObservation) diffVector];
            else
                bd(bi).(currObservation) = bd(bi).(currObservation);
            end
        end
    end



%% Create classifier observations
switch config.observations.combining
	case 'all combinations'
		for bi = 1:numel(bd)
			cur_obs = bd(bi);

			obs_perm = cellfun(@(o) 1:size(cur_obs.(o),1), observations, 'UniformOutput',false);
			obs_ind = cell(size(obs_perm));
			[obs_ind{:}] = ndgrid(obs_perm{:});
			obs_ind = cell2mat(cellfun(@(x) x(:), obs_ind, 'UniformOutput',false));
			obs_ind = mat2cell(obs_ind, ones(size(obs_ind,1),1), size(obs_ind,2));

			class_obs = cell(size(obs_ind));
			for ii = 1:numel(obs_ind)
				class_obs{ii} = cell2mat(cellfun(@(o,ri) cur_obs.(o)(ri,:), observations, num2cell(obs_ind{ii}), 'UniformOutput',false));
			end
			bd(bi).class_obs = cell2mat(class_obs);
		end
		
	case 'median'
		for bi = 1:numel(bd)
			bd(bi).class_obs = cell2mat(cellfun(@(o) median(bd(bi).(o),1), observations, 'UniformOutput',false));
		end

	otherwise
		error('vbr:obs:comb','Uniknown observations combining method.');
end

end