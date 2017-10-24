close all;
clc;
clear all;


%Load config for using. Later config will be changed.
load('Classification_config.mat')

%Set path to the training set into config.baseroot
config.baseroot = fullfile(pwd, 'dataset', 'train');

%Loading list of obsrvation functions
config.observations.list = dir('vbr_obs_*.m');
config.observations.list([config.observations.list.isdir]) = [];
config.observations.list = sort(cellfun(@(x) x(1:end-2), {config.observations.list.name}, 'UniformOutput',false));

config.parpoolEnable = 0;

%Setting path to testing set
path = fullfile(pwd, 'dataset', 'classification');

if ~exist('treeModel.mat')
    %Train classifier
    display('Training classifier')
    
    base  = vbr_process_base(config);                
    base = vbr_process_observations(base, config);
    
    class_obs = vertcat(base.class_obs);
    class_val = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), base, 'UniformOutput',false);
    class_val = vertcat(class_val{:});
    
    [cl_ind, ~, model.classes] = grp2idx(class_val);
    model.data_scale.shift = -mean(class_obs);
    model.data_scale.factor = 1./(3*std(class_obs));

    class_obs = ( class_obs+repmat(model.data_scale.shift,size(class_obs,1),1) ) .* repmat(model.data_scale.factor,size(class_obs,1),1);
    class_obs = abs(class_obs);
    
    model.model = fitctree(class_obs, cl_ind);
    save('treeModel.mat', 'model', '-mat');
    
else
    disp('Classification');
    config.baseroot = path;
    load ('treeModel.mat', '-mat');
    
    [base filenames] = vbr_process_base(config);                
    base = vbr_process_observations(base, config);
    
    class_obs = vertcat(base.class_obs);    
    class_val = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), base, 'UniformOutput',false);
    class_val = vertcat(class_val{:});
    
    [cl_ind, ~, ~] = grp2idx(class_val);
    

    class_obs = ( class_obs+repmat(model.data_scale.shift,size(class_obs,1),1) ) .* repmat(model.data_scale.factor,size(class_obs,1),1);
    cl_ind = zeros(size(class_obs,1),1);
    class_obs = abs(class_obs);
    
    [label,Posterior] = predict(model.model, class_obs)
    
%     label = abs(label)
%     Posterior = abs(Posterior)
    
end

