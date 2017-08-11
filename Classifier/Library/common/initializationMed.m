function [file,config] = initializationMed()
    %% __________________ Clean 'Out' directory ___________________________ %%
    
    fclose('all');
    dirName = fullfile(pwd,'Out');
    if ~exist(dirName, 'dir')
        mkdir(dirName)
    end
    dirData = dir(dirName);     	% Get the data for the current directory
    dirIndex = [dirData.isdir];        % Find the index for directories
    fileList = {dirData(~dirIndex).name}';	% Get a list of the files
    if ~isempty(fileList)
        fileList = cellfun(@(x) fullfile(dirName,x),fileList,'UniformOutput',false);
        cellfun(@delete, fileList);
    end
    
    %% ___________________ Check @In directory file _______________________ %%
    
       % CONFIG file checking
    configPath = fullfile(pwd,'In','config.xml');
    if ~exist(configPath,'file')
        error('There is no @config.xml file in the @In directory!'); 
    else
        config = xml2struct(configPath);
    end
    
        % Check WAV files
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
    elseif wavFilesNumber > 1
        error('Too much .wav files in the @In directory!');
    else
       
    [signal, Fs] = audioread(fileList{wavPositions,1});

    if Fs > 4000    % Signal decimation for processing acceleration
        decimateFactor = Fs/4000;
        signal = decimate(signal, decimateFactor);
        Fs = 4000;
    end

    [despiked_signal] = schmidt_spike_removal(signal, Fs);
    [heartRate, systolicTimeInterval] = getHeartRateSchmidt(signal, Fs, 1);
    
    file = [];
    file.Fs = Fs;
    file.signal = despiked_signal;

end
