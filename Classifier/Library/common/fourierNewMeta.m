clc;
clear all;
close all;


Root = fileparts(mfilename('fullpath'));
cd(Root);
add_path;

configPath = fullfile(pwd, 'In', 'config.xml');
config = xml2struct(configPath);

Parameters = [];
Parameters.printPlotsEnable = config.config.parameters.common.printPlotsEnable.Attributes.value;
Parameters.parpoolEnable = config.config.parameters.common.parpoolEnable.Attributes.value;
    

% Check WAV files
    dirName = fullfile(pwd,'In');
    dirData = dir(dirName);	% Get the data for the current directory
    dirIndex = [dirData.isdir];	% Find the index for directories
    fileList = {dirData(~dirIndex).name}';	% Get a list of the files
    
     fileList = cellfun(@(x) fullfile(dirName,x),fileList,'UniformOutput',false);
    [~,~,extentions] = cellfun(@fileparts,fileList,'UniformOutput',false);
    wavPositions = find(cellfun(@strcmp,extentions, repmat({'.wav'},size(extentions))));
    wavFilesNumber = length(wavPositions);
    
    [signal, Fs] = audioread(fileList{wavPositions,1});

if Fs > 4000
    decimateFactor = Fs/4000;
%     decimateFactor = 10;
    signal = decimate(signal, decimateFactor);
    Fs = 4000;
end

file = [];
file.Fs = Fs;
file.signal = signal;


signalLength = length(file.signal);

dt = 1/Fs;
tmax = dt*signalLength;
t = 0:dt:tmax-dt;
m = tmax*Fs;
df = Fs/signalLength;
f = 0:df:Fs-df;

%____________________________________
if Parameters.printPlotsEnable
    h = figure 
    plot(t, signal), title('Signal');
    xlabel('Time (Sec)');
    ylabel('Amplitude');
    
end
LF = 5;
HF = 60;
MinPeakHeight = 0.00005;
MinPeakDistance = 0.6;
[ filteredSignal] = spectrumFiltration(file, t, LF, HF, MinPeakHeight, MinPeakDistance);

% Signal plotting & saving

if Parameters.printPlotsEnable
    h = figure 
    plot(t, signal), title('Signal');
    xlabel('Time (Sec)');
    ylabel('Amplitude');
    
end
fileName = 'Original signal';
fullFilePath = fullfile(pwd,'Out');
fullFileName = fullfile(fullFilePath,fileName);
print(fullFileName,'-djpeg91', '-r180');
savefig(h, fullFileName, 'compact');

% Spectrum calculation, plotting & saving

spectrum = abs(fft(signal));
if Parameters.printPlotsEnable
    h = figure 
%     plot(f(1:1801),spectrum(1:1801)), title('Signal spectrum');
    plot(f,spectrum), title('Signal spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    
end
fileName = 'Signal spectrum';
fullFilePath = fullfile(pwd,'Out');
fullFileName = fullfile(fullFilePath,fileName);
print(fullFileName,'-djpeg91', '-r180');
savefig(h, fullFileName, 'compact');

% Spectrogram
% figure, spectrogram (signal);

function [filteredSignal] = spectrumFiltration(file, t, LF, HF, MinPeakHeight, TimePeakDistance)
    
    filterBank = [5, 60; 10, 65; 15, 70; 20, 75; 25, 80; 30, 85; 35, 90; 40, 95; 45, 100]
    
    Fs = file.Fs;
    
	spec = fft(file.signal);
	df = file.Fs/ length(file.signal);
    f = 0:df:Fs-df;
    dt = 1 / Fs;
    MinPeakDistance = TimePeakDistance / dt;   
    
    for i =1:length(filterBank(:,1))
    lowFrequency = filterBank(i,1);
    highFrequency = filterBank(i,2);
    

% cutting off stop band

	
	f_valid = (f > lowFrequency) & (f < highFrequency);
	spec_valid = spec;
	spec_valid(~f_valid) = 0;
	filteredSignal(i,:) = ifft(spec_valid,'symmetric');
       
    figure;
    findpeaks(filteredSignal(i, :), t, 'MinPeakHeight',MinPeakHeight,'MinPeakDistance',TimePeakDistance);    
    [pks, locs] = findpeaks(filteredSignal(i, :), 'MinPeakHeight',MinPeakHeight,'MinPeakDistance',MinPeakDistance);
    title([ 'spectrum filtered signal' num2str(i) 'in freq band: ' num2str(lowFrequency) ', ' num2str(highFrequency)]), xlabel('Time (Sec)'), ylabel('Amplitude');
    
	   
	fileName = 'Spectrum Filtered Signal';
	fullFilePath = fullfile(pwd,'Out');
	fullFileName = fullfile(fullFilePath,fileName);
	print(fullFileName,'-djpeg91', '-r180');
%     audiowrite(strcat('Out\specFiltered', num2str(i), '.wav'), filteredSignal, Fs);
    end
end
