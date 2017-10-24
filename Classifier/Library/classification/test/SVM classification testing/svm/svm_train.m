function result = svm_train(base, config, info)
    
    class_obs = vertcat(base.class_obs);
    class_val = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), base, 'UniformOutput',false);
    class_val = vertcat(class_val{:});
    if ~ischar(class_val{1,1})
        class_val = cellfun(@(x) num2str(x),class_val, 'UniformOutput',false);
    end
    % Estimate best train parameters
    disp('Estimating best SVM parameters...');
    if config.findbest
        [~, ~, predict, command] = lib_svm.find_cost_gamma(class_obs, class_val, 'autoweight',config.classification.autoweight,...
                                                                                 'autoscale',config.classification.autoscale,...
                                                                                 'fold',config.classification.fold_number);
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
    
    result.model = lib_svm.train(class_obs, class_val, [result.command, ' -s ',config.classification.svmType,...
                                                                        ' -b ',config.classification.probabilityEnable,...
                                                                        ' -t ',config.classification.kernelType] );
                                                                    
    
    if config.classification.ratemodel
        
        ratemodel = lib_svm.train(class_obs, class_val, [result.command, ' -v 10', ' -s ',config.classification.svmType, ' -b ',config.classification.probabilityEnable, ' -t ',config.classification.kernelType] ); % for SVM
        class_ind = cellfun(@(x) find(strcmp(ratemodel.classes,x)), class_val);     % for SVM
        cm = confusionmat(class_ind, ratemodel.model, 'order',1:numel(ratemodel.classes));
        cmn = cm ./ repmat(sum(cm,2),1,size(cm,2));
        result.ratemodel.confusion.matrix = cm;
        result.ratemodel.confusion.order = ratemodel.classes;
        result.ratemodel.confusion.accuracy = trace(result.ratemodel.confusion.matrix) / sum(result.ratemodel.confusion.matrix(:));
        result.ratemodel.confusion.average_recall = mean(diag(cmn));
        result.ratemodel.class_val = ratemodel.model;
    end
    
    
end