function result = vbr_process(config)
%vbr_process The main vibration base processing function.

%============= WORK ========================
% % 
% % if exist('base.mat', 'file')
% % 
% %     load('base.mat');
% %     
% %     base1 = vbr_process_base(config); %struct that contains 2 fields: filename and class
% %     base1 = vbr_process_observations(base1, config);
% %     base = cat(1, base, base1);
% % 
% %     % Build and test classifier
% %     result = vbr_process_classification(base, config);
% %     
% % if exist ('model.mat', 'file')
% % %     path = fullfile(pwd,'dataset','testSet');
% % %     result = Classification_fun(config, path);
% %     load ('result.mat');
% %     load ('base.mat');
% %     SAMPLE=vertcat(base.class_obs);
% %     CL_RES = result.model.classify(SAMPLE); %Классифицируем.
% %     save('classification.mat', 'CL_RES', '-mat');
% % 
% % else
    % Load base list
    base = vbr_process_base(config);
%     save('base_3.mat', 'base', '-mat');
    % Calculate observations
    base = vbr_process_observations(base, config);
%     save('base_4.mat', 'base', '-mat');
    % Build and test classifier
    result = vbr_process_classification(base, config);
%     save('res.mat', 'result', '-mat');
% %     model = result.model;
% %     save('model.mat', 'model', '-mat');
% %     save ('base.mat', 'base', '-mat');
% %     save ('result.mat', 'result', '-mat');
 end
