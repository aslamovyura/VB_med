function [] = sortFiles ()
%This function sort dataset into 2 folders: '1' & '-1', according to their
%class (1, -1), which should be specified in 'In/REFERENCE.csv'

filename = fullfile(pwd,'In','REFERENCE.csv');
M = importdata(filename);
class = M.data(:);

dirName = fullfile(pwd,'In/1');
    if ~exist(dirName, 'dir')
        mkdir(dirName)
    end
dirName = fullfile(pwd,'In/-1');
    if ~exist(dirName, 'dir')
        mkdir(dirName)
    end

dirName = fullfile(pwd,'In');
    dirData = dir(dirName);	% Get the data for the current directory
    dirIndex = [dirData.isdir];	% Find the index for directories
    fileList = {dirData(~dirIndex).name}';	% Get a list of the files
    
    if isempty(fileList)
       error('The @In directory is empty!'); 
    end
    
    fileList = cellfun(@(x) fullfile(dirName,x),fileList,'UniformOutput',false);
    [~,~,extentions] = cellfun(@fileparts,fileList,'UniformOutput',false);
    wavPositions = find(cellfun(@strcmp,extentions, repmat({'.wav'},size(extentions))));
    wavFilesNumber = length(wavPositions);
    
    if wavFilesNumber == 0
        error('There is no .wav files in the @In directory!');
    end     
    
    for i = 1:wavFilesNumber
        if class(i)==1
            copyfile(fileList{wavPositions(i)}, fullfile(pwd,'In/1'))
        else
            copyfile(fileList{wavPositions(i)}, fullfile(pwd,'In/-1'))
        end
    end
end