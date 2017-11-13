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
    
    %using 1-st channel of signal
    if size(signal, 2) > 1 
        signal = signal(:, 1);
    end
    
    % upd on Nov. 13th, 2017 by I. Trus:
    % decimation for signals with Fs > 4000 Hz
    % cubic interpolation for signals with Fs < 4000 Hz
    targetFs = 4000;
    if Fs > targetFs 
        decimateFactor = round(Fs/targetFs);
        signal = decimate(signal, decimateFactor);
        Fs = targetFs;
    elseif Fs < targetFs    
        len = length(signal);
        dt = 1/Fs;
        tmax = dt*len;
        t = 0:dt:tmax-dt;
        
        signal = resample(signal, t, targetFs, targetFs, Fs, 'pchip');
        Fs = targetFs;
    end
    
    %band-pass signal filtration 25-400Hz 4th order Butterworth 
    signal = butterworth_low_pass_filter(signal,2,400,Fs, false);
    signal = butterworth_high_pass_filter(signal,2,25,Fs);
    
    %removing spikes from signal
    signal = schmidt_spike_removal(signal, Fs);
    
    %signal normalizartion
    signalMaximum = max(abs(signal));
    signal = signal./signalMaximum;

    file = [];
    file.Fs = Fs;
    file.signal = signal;

end
