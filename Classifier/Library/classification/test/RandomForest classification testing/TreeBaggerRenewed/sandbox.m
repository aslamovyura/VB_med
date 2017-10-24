close all;
% clc;
clear all;

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

base  = tre_create_BD(config);
[segments, base] = tre_segments_extraction_signal(base, config);
base = tre_fill_in_BD_signal(base, segments, config);

class_obs = vertcat(base.class_obs);
class_val = arrayfun(@(x) repmat({x.class},size(x.class_obs,1),1), base, 'UniformOutput',false);
class_val = vertcat(class_val{:});

[cl_ind, ~, model.classes] = grp2idx(class_val);
model.data_scale.shift = -mean(class_obs);
model.data_scale.factor = 1./(3*std(class_obs));

class_obs = ( class_obs+repmat(model.data_scale.shift,size(class_obs,1),1) ) .* repmat(model.data_scale.factor,size(class_obs,1),1);
class_obs = abs(class_obs);


% c = cvpartition(cl_ind,'k',10); % using cross-validation 
opts = statset('display','iter');
fun = @(XT,yT,Xt,yt)...
      (sum(yt ~= classify(Xt,XT,yT,'quadratic')));

% [fs,history] = sequentialfs(fun,class_obs,cl_ind,'cv',c,'options',opts) % using cross-validation
[fs,history] = sequentialfs(fun,class_obs,cl_ind,'options',opts)
