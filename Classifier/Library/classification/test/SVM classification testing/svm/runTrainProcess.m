% clc;
clear all; close all;
% add_path;
% function result =  runTrainProcess (trainData, config)

addpath(fullfile(pwd, 'thirdpart'));
addpath(fullfile(pwd, 'thirdpart', 'challenge2016'));
addpath(fullfile(pwd, 'thirdpart', 'libsvm'));
addpath(fullfile(pwd, 'thirdpart', 'libsvm', 'src'));
addpath(fullfile(pwd, 'thirdpart', 'libsvm', 'src', 'matlab'));
addpath(fullfile(pwd, 'thirdpart', 'libsvm', 'src', 'windows'));
addpath(fullfile(pwd, 'thirdpart', 'MFCC'));
    % --------------------- Configuration ------------------------------- %
    for i = 1:3
    mode = 'create'; % load / create   BD of pattern to train SVM


    config.observations.list = dir('tr_obs_*.m');
    config.observations.list([config.observations.list.isdir]) = [];
    config.observations.list = sort(cellfun(@(x) x(1:end-2), {config.observations.list.name}, 'UniformOutput',false));

    config.observations.combining = 'median';   % median/ all combinations;  
    config.classification.findbest = 1;         % find best parameters C and gamma
    config.classification.autoweight = 1;       % auweight classes for balance
    config.classification.autoscale = 1;        % autoscale train data
    config.classification.fold_number = 10;     % for cross-validation
    config.classification.ratemodel = 1; 
    config.classification.kernelType = '0';     %       0 -- linear: u'*v
                                                %       1 -- polynomial: (gamma*u'*v + coef0)^degree
                                                %       2 -- radial basis function: exp(-gamma*|u-v|^2)
                                                %       3 -- sigmoid: tanh(gamma*u'*v + coef0)
                                                %       4 -- precomputed kernel (kernel values in training_set_file)

    config.classification.svmType = '0';        %       0 -- C-SVC
                                                %       1 -- nu-SVC
                                                %       2 -- one-class SVM
                                                %       3 -- epsilon-SVR
                                                %       4 -- nu-SVR

    config.classification.probabilityEnable = '1';  %   0 -- disable
                                                    %   1 -- enable
    
    config.classification.parpoolEnable = '0';  %   0 -- disable
                                                %   1 -- enable
                                                    
%     config.classificationEnable = 1;
    config.dataset.baseroot = fullfile(pwd, 'testing_dataset', 'train');
%     config.dataset.baseroot = fullfile(pwd, 'signals', 'train');
    % --------------------------- Computation ---------------------------- %

    switch(mode)
        case 'load'
            load('bd_pattern.mat');
        case 'create'
            bd_train = tre_create_BD(config);
            save('bd_pattern.mat','bd_train','-v7.3');
        otherwise
    end

    % Fill BD struct with patterns parameters and add tags for each class
    %% For full signal
%     bd_train_signal = tre_fill_in_BD_signal_old(bd_train, config);

    %Creating BD of segments for each signal in dataset
    disp('Creating train base');
    [segments_train, bd_train] = tre_segments_extraction_signal(bd_train, config);
    
    [bd_train_signal] = tre_fill_in_BD_signal(bd_train, segments_train, config);
    
%     [bd_train_signal] = tre_fill_bd_to_full_size(bd_train_signal, config);
    % Train SVM classifier and build rated model
    disp('Classifier training');
    [svm_model_signal, class_val] = tr_train(bd_train_signal, config);
    svm_model_signal.observations = config.observations.list;
%     save('svm_model_signal.mat', 'svm_model_signal');
%     svm_model_signal.config.classification = config.classification;

    bd_train_signal = arrayfun(@(x,y) setfield(x, 'value', y), bd_train_signal, svm_model_signal.ratemodel.class_val');
   
    %% Feature selection using sequentialfs%% 
    disp('Feature selection using sequentialfs');
    % c = cvpartition(cl_ind,'k',10); % using cross-validation 
    opts = statset('display','iter');
    fun = @(XT,yT,Xt,yt)...
      (sum(yt ~= classify(Xt,XT,yT,'quadratic')));
    class_obs = vertcat(bd_train_signal.class_obs);
    class_obs = ( class_obs+repmat(svm_model_signal.model.data_scale.shift,size(class_obs,1),1) ) .* repmat(svm_model_signal.model.data_scale.factor,size(class_obs,1),1);
    class_obs = abs(class_obs);
    [cl_ind, ~, sv_model_signal.classes] = grp2idx(class_val);
    % [fs,history] = sequentialfs(fun,class_obs,cl_ind,'cv',c,'options',opts) % using cross-validation
    [fs,history] = sequentialfs(fun,class_obs,cl_ind,'options',opts);
    
    %% Feature selection using PCA method
% %     disp('Feature selection using PCA method');
% %     bd_train_signal_pca = bd_train;
% %     [~, class_obs_pca, ~] = pca(class_obs);
% %     for i = 1:numel(bd_train_signal_pca)
% %         bd_train_signal_pca(i).class_obs = class_obs_pca(i, :);
% %     end
% %     disp('Classifier retraining using PCA method');
% %     [svm_model_signal_pca] = tr_train(bd_train_signal_pca, config);
    
    %% Retrain SVM classifier with sequentialfs %%
    disp('Classifier retraining using sequentialfs');
    bd_train_signal_r = bd_train;
    for i = 1:numel(bd_train_signal_r)
        bd_train_signal_r(i).class_obs = class_obs(i, fs);
    end
    [svm_model_signal_r] = tr_train(bd_train_signal_r, config);
    
    
    
    %% Creating test base
%     config.dataset.baseroot = fullfile(pwd, 'In');
    config.dataset.baseroot = fullfile(pwd, 'testing_dataset', 'classification');
%     config.dataset.baseroot = fullfile(pwd, 'signals', 'classification');
    disp('Creating test base');
    [bd_test] = tre_create_BD(config);
%     bd_test_signal = tre_fill_in_BD_signal_old(bd_test, config);  
    [segments_test, bd_test] = tre_segments_extraction_signal(bd_test, config);
    [bd_test_signal] = tre_fill_in_BD_signal(bd_test, segments_test, config);
    
%     [bd_test_signal] = tre_fill_bd_to_full_size(bd_test_signal, config);
    
    bd_obs = vertcat(bd_test_signal.class_obs);
    true_class_value = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), bd_test_signal, 'UniformOutput',false);
    true_class_value = vertcat(true_class_value{:});

 
    
    %% Test Classification for initial classifier
% %     observations = elem_svm_classifier.observations;
% %     base_obs = cell(numel(bd_test),1);
% %     for bi = 1:1:numel(bd_test)
% %         base_obs{bi} = cellfun(@(x) bd_test(bi).(x),observations, 'UniformOutput', false)';
% %     end
% %     base_obs = cell2mat(cellfun(@(x) cell2mat(x),base_obs,'UniformOutput', false));
% % 
% %     [result, prob_vec] = classify_libsvm(elem_svm_classifier.model, base_obs, config);

%     bd_test = cell2mat(cellfun(@(x) cell2mat(x),base_obs,'UniformOutput', false));
    disp('Initial classifier testing');
    bd_obs = vertcat(bd_test_signal.class_obs);
    [result_class_value_signal, prob_vec] = classify_libsvm(svm_model_signal.model, bd_obs, config);
    
    threshold = 0.5;
    accuracy = nnz(max(prob_vec, [], 2) > threshold)/size(prob_vec,1);
    
    %% Test Classification for retrained classifier with sequentialfs
    disp('Retrained classifier testing using sequentialfs');   
    bd_obs_r = bd_obs(:, fs);
    [result_class_value_signal_r, prob_vec_r] = classify_libsvm(svm_model_signal_r.model, bd_obs_r, config);
    
    accuracy_r = nnz(max(prob_vec_r, [], 2) > threshold)/size(prob_vec_r,1);
    
    %% Test Classification for retrained classifier with/without PCA on testset
% %     disp('Retrained classifier testing using PCA method with PCA on testset'); 
% %     [~, bd_obs_pca, ~] = pca(bd_obs);
% %     
% %     [result_class_value_signal_pca, prob_vec_pca] = classify_libsvm(svm_model_signal_pca.model, bd_obs_pca, config);
% %     
% %     accuracy_pca = nnz(max(prob_vec_pca, [], 2) > threshold)/size(prob_vec_pca,1);
% %     
% %     disp('Retrained classifier testing using PCA method w/o PCA on testset');
% %     [result_class_value_signal_pca_2, prob_vec_pca_2] = classify_libsvm(svm_model_signal_pca.model, bd_obs, config);
% %     
% %     accuracy_pca_2 = nnz(max(prob_vec_pca_2, [], 2) > threshold)/size(prob_vec_pca_2,1);
    %% Initial classifier evaluation %% 
    disp('Initial classifier evaluating');
    cp_signal = classperf(true_class_value);
    cp_signal = classperf(cp_signal, result_class_value_signal)
    get(cp_signal, 'CountingMatrix')
    
    %% Retreained with sequentialfs classifier evaluation %%
    disp('Retrained classifier evaluating using sequentialfs');
    cp_signal_r = classperf(true_class_value);
    cp_signal_r = classperf(cp_signal_r, result_class_value_signal_r)
    get(cp_signal_r, 'CountingMatrix')

    %% Retreained with PCA method classifier evaluation with/without PCA on testset
% %     disp('Retrained classifier evaluating using PCA method with PCA on testset');
% %     cp_signal_pca = classperf(true_class_value);
% %     cp_signal_pca = classperf(cp_signal_pca, result_class_value_signal_pca)
% %     get(cp_signal_pca, 'CountingMatrix')
% %     
% %     disp('Retrained classifier evaluating using PCA method w/o PCA on testset');
% %     cp_signal_pca_2 = classperf(true_class_value);
% %     cp_signal_pca_2 = classperf(cp_signal_pca_2, result_class_value_signal_pca_2)
% %     get(cp_signal_pca_2, 'CountingMatrix')
%% For segments of the signal (work)
% %  % Fill BD struct with patterns parameters and add tags for each class
% %     % for full signal
% %     disp('Creating train base')
% %     bd_train_segments = tre_fill_in_BD_segments(bd_train, config);
% %     
% %     bd_train_segments_new = tre_fill_mean_BD(bd_train, bd_train_segments, config)
% % 
% %     
% %     
% %     % Train SVM classifier and build rated model
% %     disp('Training');
% %     [svm_model_segments] = tr_train(bd_train_segments,config);
% %     svm_model_segments.observations = config.observations.list;
% %     save('svm_model_segments.mat', 'svm_model_segments');
% %     svm_model_segments.config.classification = config.classification;
% % 
% %     
% %     bd_train_segments = arrayfun(@(x,y) setfield(x, 'value', y), bd_train_segments, svm_model_segments.ratemodel.class_val');
% %    
% % %     config.dataset.baseroot = fullfile(pwd, 'In');
% %     config.dataset.baseroot = fullfile(pwd, 'testing_dataset', 'classification');
% %     disp('Creating testing base');
% %     
% %     [bd_test] = tre_create_BD(config);
% %     bd_test_segments = tre_fill_in_BD_segments(bd_test, config);
% %     
% %     
% %   
% % % %     true_class_value_segments = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), bd_test_segments, 'UniformOutput',false);
% % % %     true_class_value_segments = vertcat(true_class_value_segments{:});    
% % 
% %     % Test Classification of the 10% of dataset
% % % %     observations = elem_svm_classifier.observations;
% % % %     base_obs = cell(numel(bd_test),1);
% % % %     for bi = 1:1:numel(bd_test)
% % % %         base_obs{bi} = cellfun(@(x) bd_test(bi).(x),observations, 'UniformOutput', false)';
% % % %     end
% % % %     base_obs = cell2mat(cellfun(@(x) cell2mat(x),base_obs,'UniformOutput', false));
% % % % 
% % % %     [result, prob_vec] = classify_libsvm(elem_svm_classifier.model, base_obs, config);
% % 
% % %     bd_test = cell2mat(cellfun(@(x) cell2mat(x),base_obs,'UniformOutput', false));
% % disp('Testing');
% %     bd_obs = vertcat(bd_test_segments.class_obs);
% %     [result_class_value_segments, prob_vec] = classify_libsvm(svm_model_segments.model, bd_obs, config);
% %     
% %     threshold = 0.5;
% %     accuracy = nnz(max(prob_vec, [], 2) > threshold)/size(prob_vec,1);
% %     
% % %     for i = 1:size(bd_test, 1)
% % %         k = 1;
% % %         for j = 1:size(bd_test_segments, 2)
% % % 
% % %             if strcmp(bd_test(i).filename, bd_test_segments(j).filename) == 1
% % %                 currentTrueSignal(k).class = bd_test_segments(j).class;
% % %                 currentResultSignal(k).class = result_class_value_segments(j);
% % %                 k = k + 1;
% % %             end
% % %         end
% % %         compareString = 'Normal';
% % %         trueNormalElements = 0;
% % %         trueAbnormalElements = 0;
% % %         resultAbnormalElements = 0;
% % %         resultNormalElements = 0;
% % %         for k = 1:length(currentTrueSignal)
% % %             if strcmp(currentTrueSignal(k).class, compareString)
% % %                 currentTrueSignal(k).class = 1;
% % %                 trueNormalElements = trueNormalElements + 1;
% % %             else
% % %                 currentTrueSignal(k).class = 0;
% % %                 trueAbnormalElements = trueAbnormalElements + 1;
% % %             end
% % %             if strcmp(currentResultSignal(k).class, compareString)
% % %                 currentResultSignal(k).class = 1;
% % %                 resultNormalElements = resultNormalElements + 1;
% % %             else
% % %                 currentResultSignal(k).class = 0;
% % %                 resultAbnormalElements = resultAbnormalElements + 1;
% % %             end
% % %         end
% % %         if trueNormalElements > trueAbnormalElements
% % %             trueSignalClass = 'Normal';
% % %         else
% % %             trueSignalClass = 'Abnormal';
% % %         end
% % %         if resultNormalElements > resultAbnormalElements
% % %             resultSignalClass = 'Normal';
% % %         else
% % %             resultSignalClass = 'Abnormal';
% % %         end
% % %         trueSignal(i).filename = bd_test(i).filename;
% % %         trueSignal(i).class = trueSignalClass;
% % %         
% % %         resultSignal(i).filename = bd_test(i).filename;
% % %         resultSignal(i).class = resultSignalClass;
% % %         
% % %         clearvars trueSignalClass resultSignalClass currentResultSignal currentTrueSignal;
% % %     end
% %     true_signal_classes_segments = arrayfun(@(x) repmat({x.class},size(x.class,1),1), trueSignal, 'UniformOutput',false);
% %     true_signal_classes_segments = vertcat(true_signal_classes_segments{:});
% %     
% %     result_signal_classes_segments = arrayfun(@(x) repmat({x.class},size(x.class,1),1), resultSignal, 'UniformOutput',false);
% %     result_signal_classes_segments = vertcat(result_signal_classes_segments{:});
% %     
% %     cp_segments = classperf(true_signal_classes_segments)
% %     classperf(cp_segments, result_signal_classes_segments)
    end