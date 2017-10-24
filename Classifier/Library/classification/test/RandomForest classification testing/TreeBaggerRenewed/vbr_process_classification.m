function result = vbr_process_classification(base, config)
%vbr_process_classification Creates and tests classifier

class_obs = vertcat(base.class_obs);
class_val = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), base, 'UniformOutput',false);
class_val = vertcat(class_val{:});

% Estimate best train parameters
if config.classification.findbest
	[~, ~, predict, command] = lib_svm.find_cost_gamma(class_obs, class_val, config.parpoolEnable, 'autoweight',config.classification.autoweight);
	[accuracy, average_recall, ~, conf_mat, order] = lib_svm.rate_prediction(class_val, predict);
	if config.classification.autoweight
		[mv, mi] = max(average_recall);
	else
		[mv, mi] = max(accuracy);
	end
	result.findbest = struct('rate',mv, 'confusion',struct('matrix',conf_mat{mi}, 'order',order(mi)));
	result.command = command{mi};
else
	result.command = config.classification.svm_command;
end

comand = result.command;
str2 = ' -q';
str3 = ' -b 1';
command = strrep(comand,str2,str3);
result.command = command;

% Build final model
result.model = lib_svm.train(class_obs, class_val, result.command);

% Rate final model performance
if config.classification.ratemodel
	ratemodel = lib_svm.train(class_obs, class_val, [result.command ' -v 10']);
	class_ind = cellfun(@(x) find(strcmp(ratemodel.classes,x)), class_val);
	cm = confusionmat(class_ind, ratemodel.model, 'order',1:numel(ratemodel.classes));
	cmn = cm ./ repmat(sum(cm,2),1,size(cm,2));
	result.ratemodel.confusion.matrix = cm;
	result.ratemodel.confusion.order = ratemodel.classes;
	result.ratemodel.confusion.accuracy = trace(result.ratemodel.confusion.matrix) / sum(result.ratemodel.confusion.matrix(:));
	result.ratemodel.confusion.average_recall = mean(diag(cmn));
end
