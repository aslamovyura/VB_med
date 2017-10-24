function [base filenames] = vbr_process_base(config)
%vbr_process_base The vibration base processing function: just load list.

%% Load classes list
dlist = dir(config.baseroot);
dlist(~[dlist.isdir]) = [];
dlist = {dlist.name}';
dlist(strcmp(dlist,'.')) = [];
dlist(strcmp(dlist,'..')) = [];

%% List all supported files
ext_list = {'wav' 'ogg' 'flac' 'fla' 'au' 'mp3' 'm4a' 'mp4'};

base = cell(numel(dlist),1);
for li = 1:numel(dlist)
	subroot = fullfile(config.baseroot,dlist{li});
	flist = cell2mat(cellfun(@(ex) dir(fullfile(subroot,['*.' ex])), ext_list(:), 'UniformOutput',false));
	flist([flist.isdir]) = [];
	base{li} = struct('filename',fullfile(subroot, {flist.name}'), 'class', dlist{li});
    
end
filenames = {flist.name}';
base = cell2mat(base);
