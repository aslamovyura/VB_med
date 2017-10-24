function [ base, true_class_value ] = tre_create_BD( config )


%% Load dataset list

    dlist = dir(config.dataset.baseroot);

    dlist(~[dlist.isdir]) = [];
    dlist = {dlist.name}';
    dlist(strcmp(dlist,'.')) = [];
    dlist(strcmp(dlist,'..')) = [];
    disp('Creating base ...');

    ext_list = {'wav' 'ogg' 'flac' 'fla' 'au' 'mp3' 'm4a' 'mp4'};

    base = cell(numel(dlist),1);
    % if config.parpoolEnable
    %     parfor i = 1:numel(dlist)
    %         subroot = fullfile(config.dataset.baseroot,dlist{li});
    %         flist = cell2mat(cellfun(@(ex) dir(fullfile(subroot,['*.' ex])), ext_list(:), 'UniformOutput',false));
    %         flist([flist.isdir]) = [];
    %         base{li} = struct('filename',fullfile(subroot, {flist.name}'), 'class', dlist{li});
    %     end
    % else
        for li = 1:numel(dlist)
            subroot = fullfile(config.dataset.baseroot,dlist{li});
            flist = cell2mat(cellfun(@(ex) dir(fullfile(subroot,['*.' ex])), ext_list(:), 'UniformOutput',false));
            flist([flist.isdir]) = [];
            base{li} = struct('filename',fullfile(subroot, {flist.name}'), 'class', dlist{li});
        end
    % end
    base = cell2mat(base); 

end




function [class_num] = class2num(class_name)

switch(class_name)
    
    case 'Normal'
        class_num = 1;
    case 'Abmormal'
        class_num = 2;

    otherwise
        error('cls:class_name','Incorrect class_name');
end

% switch(class_name)
%     
%     case 'bearing'
%         class_num = 1;
%     case 'bearing-res'
%         class_num = 2;
%     case 'belting'
%         class_num = 3;
%     case 'gearing'
%         class_num = 4;
%     case 'gearing-res'
%         class_num = 5;
%     case 'generator'
%         class_num = 6;
%     case 'generator-res'
%         class_num = 7;
% %     case 'unknown'
% %         class_num = 8;
%     otherwise
%         error('cls:class_name','Incorrect class_name');
% end

% switch(class_name)
%     
%     case 'shaft-bearing'
%         class_num = 1;
%     case 'bearing-res'
%         class_num = 2;
%     case 'gearing'
%         class_num = 3;
%     case 'gearing-res'
%         class_num = 4;
%     case 'belting-generator'
%         class_num = 5;
%     case 'belting-bearing'
%         class_num = 6;
%     case 'generator'
%         class_num = 6;    
%     case 'generator-res'
%         class_num = 7;    
%     otherwise
%         error('cls:class_name','Incorrect class_name');
% end
end

