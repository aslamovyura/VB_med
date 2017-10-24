% function [ train_bd, test_bd ] = tre_fill_in_BD( bd, config, info )
function [ bd_obs] = tre_fill_in_BD_segments( bd, config, info )
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
    for bi = 1:numel(bd)
        [x, fs] = audioread(bd(bi).filename);
        channel = 1;
        if fs > 1000
            decimationFactor = fs/1000;
            fs = 1000;
            x = decimate(x, decimationFactor);
        end
        x = x(:, channel);
%         x = x(1:10*fs);
        
        file.signal = x;
        file.Fs = fs;
        x = springerMethod(file);
        
        for si = 1 : size(x.rr, 2)
            x_info{si} = bd(bi);
            x_info{si}.fs = fs;
            x_new = [];
            x_new.rr{1} = x.rr{si};
            x_new.s1{1} = x.s1{si};
            x_new.s2{1} = x.s2{si};
            x_new.systole{1} = x.systole{si};
            x_new.diastole{1} = x.diastole{si};
            for oi = 1:numel(observations)
                x_info{si}.(observations{oi}) = feval(observations{oi}, x_new, config, x_info);
            end
        end
        bd_obs{bi} = x_info;
    end
% end
for bdi = 1:size(bd_obs, 2)
    bd_obs{bdi} = cell2mat(bd_obs{bdi});
end
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

