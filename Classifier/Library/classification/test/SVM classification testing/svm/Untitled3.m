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
%     config.dataset.baseroot = fullfile(pwd, 'testing_dataset', 'train');
    config.dataset.baseroot = fullfile(pwd, 'signals', 'train');
    % --------------------------- Computation ---------------------------- %

    switch(mode)
        case 'load'
            load('bd_pattern.mat');
        case 'create'
            bd_train = tre_create_BD(config);
            save('bd_pattern.mat','bd_train','-v7.3');
        otherwise
    end
    
    [segments_train, bd_train] = tre_segments_extraction_signal(bd_train, config);
    
    [bd_train_signal] = tre_fill_in_BD_signal(bd_train, segments_train, config);
    
% Train SVM model using cross-validation
    groups = ismember(bd_train.class, 'Normal');
    k = str2double(config.classification.fold_number);
    cvFolds = crossvalind('Kfold', groups, k);
    cp = classperf(groups);  
    for i = 1:k
        [svm_model_signal] = tr_train(bd_train_signal, config);
        svm_model_signal.observations = config.observations.list;
        
        base_obs = vertcat(bd_train_signal.class_obs);
%         observations = svm_model_signal.observations;
%         base_obs = cell(numel(bd_train),1);
%         for bi = 1:1:numel(bd_train)
%             base_obs{bi} = cellfun(@(x) bd_train_signal(bi).(x),observations, 'UniformOutput', false)';
%         end
%         base_obs = cell2mat(cellfun(@(x) cell2mat(x),base_obs,'UniformOutput', false));
% 
%         [result, prob_vec] = classify_libsvm(svm_model_signal.model, base_obs, config);
% 
%         bd_train = cell2mat(cellfun(@(x) cell2mat(x),base_obs,'UniformOutput', false));
    end