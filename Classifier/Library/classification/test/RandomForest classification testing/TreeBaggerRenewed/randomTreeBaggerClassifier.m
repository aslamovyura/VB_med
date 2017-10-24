close all;
% clc;
clear all;
for i = 1:5
addpath(fullfile(pwd, 'thirdpart', 'challenge2016'));
addpath(fullfile(pwd, 'thirdpart', 'MFCC'));
%Load config for using. Later config will be changed.
load('Classification_config.mat')

%Set path to the training set into config.baseroot
config.baseroot = fullfile(pwd, 'signals', 'train');

%Loading list of obsrvation functions
config.observations.list = dir('tr_obs_*.m');
config.observations.list([config.observations.list.isdir]) = [];
config.observations.list = sort(cellfun(@(x) x(1:end-2), {config.observations.list.name}, 'UniformOutput',false));

config.parpoolEnable = 0;

%Setting path to testing set
path = fullfile(pwd, 'signals', 'classification');

% if ~exist('randomTreeModel.mat')
    %Train classifier
    display('Training classifier')
    
    bd_train_signal  = tre_create_BD(config);   
    [segments_train, bd_train_signal] = tre_segments_extraction_signal(bd_train_signal, config);
    bd_train_signal = tre_fill_in_BD_signal(bd_train_signal, segments_train, config);
    
    class_obs = vertcat(bd_train_signal.class_obs);
    class_val = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), bd_train_signal, 'UniformOutput',false);
    class_val = vertcat(class_val{:});
    
    [cl_ind, ~, model.classes] = grp2idx(class_val);
    model.data_scale.shift = -mean(class_obs);
    model.data_scale.factor = 1./(3*std(class_obs));

    class_obs = ( class_obs+repmat(model.data_scale.shift,size(class_obs,1),1) ) .* repmat(model.data_scale.factor,size(class_obs,1),1);
    class_obs = abs(class_obs);
    
	% this hyperparameter needs to be fine-tuned
    numberOfTrees = 30;
    
%     model.model = TreeBagger(numberOfTrees, class_obs, cl_ind);
    model.model = TreeBagger(numberOfTrees, class_obs, cl_ind, 'NVarToSample', 'all');
    
       
    %% Feature selection using sequentialfs()%% 
    % c = cvpartition(cl_ind,'k',10); % using cross-validation 
    opts = statset('display','iter');
    fun = @(XT,yT,Xt,yt)...
      (sum(yt ~= classify(Xt,XT,yT,'quadratic')));

    % [fs,history] = sequentialfs(fun,class_obs,cl_ind,'cv',c,'options',opts) % using cross-validation
    [fs,history] = sequentialfs(fun,class_obs,cl_ind,'options',opts);
    
    
    %% Retrain classifier using reduced feature space %%
    
    class_obs_r = class_obs(:,fs);
    
    modelR.data_scale.shift = -mean(class_obs_r);
    modelR.data_scale.factor = 1./(3*std(class_obs_r));
    
    class_obs_r = ( class_obs_r+repmat(modelR.data_scale.shift,size(class_obs_r,1),1) ) .* repmat(modelR.data_scale.factor,size(class_obs_r,1),1);
    class_obs_r = abs(class_obs_r);
    
%     modelR.model = TreeBagger(numberOfTrees, class_obs_r, cl_ind);
    modelR.model = TreeBagger(numberOfTrees, class_obs_r, cl_ind, 'NVarToSample', 'all');
    
    save('randomTreeModel.mat', 'model', 'modelR', 'fs', '-mat');
    
% else
    disp('Classification');
    config.baseroot = path;
    load('randomTreeModel.mat', '-mat');
    
    %% Classification using model with initial feature space%%
    
    bd_test  = tre_create_BD(config);                
%     base = tre_fill_in_BD(base, config);
    [segments_test, bd_test] = tre_segments_extraction_signal(bd_test, config);
    [bd_test_signal] = tre_fill_in_BD_signal(bd_test, segments_test, config);
    
    class_obs = vertcat(bd_test_signal.class_obs);    
    class_val = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), bd_test_signal, 'UniformOutput',false);
    class_val = vertcat(class_val{:});
    
    [cl_ind, ~, ~] = grp2idx(class_val);
    
    class_obs = ( class_obs+repmat(model.data_scale.shift,size(class_obs,1),1) ) .* repmat(model.data_scale.factor,size(class_obs,1),1);
    cl_ind = zeros(size(class_obs,1),1);
    class_obs = abs(class_obs);
    
    [result_class_value,Posterior] = predict(model.model, class_obs);
    
%     label = abs(label)
%     Posterior = abs(Posterior)
    
    %% Initial classifier evaluation %% 
    
    % form an array of actual labels
    true_class_value = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), bd_test_signal, 'UniformOutput',false);
    true_class_value = vertcat(true_class_value{:});
    
    cp_signal = classperf(grp2idx(true_class_value));
    cp_signal = classperf(cp_signal, grp2idx(result_class_value))
%     classifierEvaluation = get(cp_signal)

    %% Classification using the model with reduced feature space%%
    
    class_obs_r = class_obs(:,fs);
    
    modelR.data_scale.shift = -mean(class_obs_r);
    modelR.data_scale.factor = 1./(3*std(class_obs_r));
    
    class_obs_r = ( class_obs_r+repmat(modelR.data_scale.shift,size(class_obs_r,1),1) ) .* repmat(modelR.data_scale.factor,size(class_obs_r,1),1);
    class_obs_r = abs(class_obs_r);
    
    [result_class_value,Posterior] = predict(modelR.model, class_obs_r);
    
    %% Evaluation of the classifier with reduced feature space %% 
    
    % form an array of actual labels
    true_class_value = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), bd_test_signal, 'UniformOutput',false);
    true_class_value = vertcat(true_class_value{:});
    
    cp_signal = classperf(grp2idx(true_class_value));
    cp_signal = classperf(cp_signal, grp2idx(result_class_value))
%     classifierEvaluation = get(cp_signal)
% end
end

