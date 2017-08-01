clc;
% clear all;
close all;

tic
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

LF = 5;
HF = 60;
MinPeakHeight = 0.05;
MinPeakDistance = 0.6;
[ filteredSignal, pks, locs] = spectrumFiltration(file, t, LF, HF, MinPeakHeight, MinPeakDistance);

% Signal plotting & saving

if Parameters.printPlotsEnable
    h = figure 
    plot(t, signal, t(locs), signal(locs),'r*'), title('Signal');
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
    plot(f(1:1801),spectrum(1:1801)), title('Signal spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    
end
fileName = 'Signal spectrum';
fullFilePath = fullfile(pwd,'Out');
fullFileName = fullfile(fullFilePath,fileName);
print(fullFileName,'-djpeg91', '-r180');
savefig(h, fullFileName, 'compact');

% figure, findpeaks( signal, t, 'MinPeakHeight',0.39,'MinPeakDistance',0.8);
% title('v lob signal'), xlabel('Time (Sec)'), ylabel('Amplitude');



%% =========================== HIGHPASS FILTERING =========================== %%




% Rp = 1; Rs = 12; % default parameter
% highFrequency = 50;
% Wp = highFrequency*(2/Fs);
% Ws = (highFrequency-0.2*highFrequency)*(2/Fs);  
% 
% [n,Wn] = buttord(Wp,Ws,Rp,Rs);
% [b, a] = butter(n, Wn, 'high');
% signal = filter(b,a,signal);
% file.signal = signal;
% 
% figure, plot(t,signal,'b'), title('Filtered Signal (Highpass Filter)');
% xlabel('Time (Sec)');
% ylabel('Filtered Signal');
% leg = ['Edge Frequency: ' num2str(highFrequency) ' Hz'];
% legend(leg, 'Location', 'southeast');
% 
% fileName = 'Highpass filter (50hz)';
% fullFilePath = fullfile(pwd,'Out');
% fullFileName = fullfile(fullFilePath,fileName);
% print(fullFileName,'-djpeg91', '-r180');
% 
% Spectrum calculation
% signalSpectrum = abs(fft(signal));
% figure, plot(f, signalSpectrum), title('Filtered Signal Spectrum');
% xlabel('Frequency (Hz)');
% ylabel('Direct Specrum');


% =========================== WAVELET FILTERING =========================== %%
% parameters = [];
% parameters = config.config.parameters.evaluation.scalogramHandler;
% parameters.Attributes.parpoolEnable = config.config.parameters.common.parpoolEnable.Attributes.value;
% parameters.Attributes.printPlotsEnable = config.config.parameters.common.printPlotsEnable.Attributes.value;
% 
% % scalogram calculation
% 
% myScalogramHandler = scalogramHandler(file, parameters);
% [scalogramData, fullScalogramData] = getDecompositionCoefficients(myScalogramHandler);




% searching peaks with heigh more than cutoffLevel
% 
% fullPeaksTable = fullScalogramData.allPeaks;
% numOfPeaks = size(fullPeaksTable,2);
% cutoffLevel = 0.1;
% neededPeaksTable = [];
% for i = 1:1:numOfPeaks
%     currentPeak = fullPeaksTable(i);
%     if currentPeak.height > cutoffLevel
%         neededPeaksTable = [neededPeaksTable currentPeak];
%     end
% end
% trueScaleCount = size(neededPeaksTable, 2);

% loading results of the wavelet filtration
% 
% load('cwtTable.mat');
% load('myNewScales.mat');
% 
% filteredSignals = [];
% numberOfSignals = 0;
% 
% for i = 1:trueScaleCount
%      
%      neededScale = neededPeaksTable(i).scales;
%      freq = neededPeaksTable(i).frequencies;
%      
% 	 filteredSignal = spectrumFiltration(freq, file, t, i);
% 	 
%      if (freq > 5 && freq < 70)
%         filteredSignals = [filteredSignals filteredSignal];
%         numbeOfSignals = numberOfSignals+1;
%      end
%      
%      
%           
%      freq = num2str(freq);
%      
%      [c scaleIndex] = min(abs(myNewScales-neededScale));
%           
%      waveletSignal(i,:) = cwtTable(scaleIndex,:);
%      envelopeWaveletSignal = envelope(waveletSignal(i,:), 2 , 'peak');
% 
%      figure, findpeaks( waveletSignal(i,:), t, 'MinPeakHeight',0.39,'MinPeakDistance',0.8);
%      title(['the WF-signal ' num2str(i)]), xlabel('Time (Sec)'), ylabel('Amplitude');
%      
%      MinPeakDistance = 0.7 / dt;
%      MinPeakHeight = 0.08;
%      [pks, locs] = findpeaks( filteredSignal, 'MinPeakHeight',MinPeakHeight,'MinPeakDistance',MinPeakDistance);
%      figure, plot(t, signal, 'b', t (locs), signal(locs), 'r*');
%      title('Signal & peaks'), xlabel('Time (Sec)'), ylabel('Amplitude');
%      
%      fileName = ['Common Wavelet Filtering Signal ' num2str(i)];
%      fullFilePath = fullfile(pwd,'Out');
%      fullFileName = fullfile(fullFilePath,fileName);
%      print(fullFileName,'-djpeg91', '-r180');
%      
% %      audiowrite(strcat('Out\waveletFiltered', num2str(i), '.wav'), waveletSignal(i,:), Fs);
%     
% end

   
clear waveletSignal;

toc
% 
% function [signal, passBandFreqs] = passBandFilter(lowFrequency, highFrequency, file)
%     
%     Rp = 1; 
%     Rs = 12;
%     
%     
%     stopBandLow = lowFrequency - lowFrequency*0.1;
%     stopBandHigh = highFrequency + highFrequency*0.1;
% 
%     passBandFreqs = [lowFrequency highFrequency];
%     stopBandFreqs = [stopBandLow stopBandHigh];
% 
%     Wp = passBandFreqs*(2/file.Fs);
%     Ws = stopBandFreqs*(2/file.Fs);  
% 
%     [n,Wn] = buttord(Wp,Ws,Rp,Rs);
%     [b, a] = butter(2, Wn);
%     signal = filter(b,a,file.signal);    
%        
% end
% 
% function [pks, locs] = regionPeaks (file, MinPeakHeight, MinPeakDistance, MaxPeakDistance)
% 
%     
%     Fs = file.Fs;
%     signal = file.signal;
% 
%     signalLength = length(file.signal);
% 
%     dt = 1/Fs;
%     tmax = dt*signalLength;
%     t = 0:dt:tmax-dt;
%     
% 
%     MinPeakDistance = MinPeakDistance / dt;
%     window = MaxPeakDistance / dt;
%     step = (MinPeakDistance + window) / 2;
%     borders = (window - MinPeakDistance) / 2;
%     pks = [];
%     locs = [];
%     N = ceil (signalLength / window);
%     nextStart = 1;
% 
%     
%     [p, lo] = findpeaks( signal(nextStart: nextStart + window), [nextStart : nextStart + window],'MinPeakHeight', MinPeakHeight, 'MinPeakDistance', MinPeakDistance);
%     e = length(lo);
%     pks = [pks, p];
%     locs = [locs, lo];
%     nextMiddle = lo(e) + step;
%     p = [];
%     lo = [];
%     while (nextMiddle < signalLength) %!!!!!!!!!
%        [ p, lo] = findpeaks( signal(nextMiddle - borders : nextMiddle + borders), [nextMiddle - borders : nextMiddle + borders],'MinPeakHeight', MinPeakHeight, 'NPeaks', 1)
%        e = length(lo);
%     pks = [pks, p(e)];
%     locs = [locs, lo(e)];
%     nextMiddle = lo(e) + step;
%     p = [];
%     lo = [];
%        
%     end
%     
%     
%     figure, plot(t, signal, 'b', t (locs), signal(locs), 'r*');
% end

function [filteredSignal, pks, locs] = spectrumFiltration(file, t, LF, HF, MinPeakHeight, MinPeakDistance)

%  	lowFrequency = frequency - 0.1*frequency;
% 	highFrequency = frequency + 0.1*frequency;
    lowFrequency = LF;
    highFrequency = HF;

	Fs = file.Fs;
	spec = fft(file.signal);
	df = file.Fs/ length(file.signal);
    dt = 1 / Fs;
% cutting off stop band

	f = 0:df:Fs-df;
	f_valid = (f > lowFrequency) & (f < highFrequency);
	spec_valid = spec;
	spec_valid(~f_valid) = 0;
	filteredSignal = ifft(spec_valid,'symmetric');
       
    figure;
    findpeaks(filteredSignal, t, 'MinPeakHeight',MinPeakHeight,'MinPeakDistance',MinPeakDistance);
    MinPeakDistance = MinPeakDistance / dt;
    [pks, locs] = findpeaks(filteredSignal, 'MinPeakHeight',MinPeakHeight,'MinPeakDistance',MinPeakDistance);
    title([ 'spectrum filtered signal in low - high freq: ' num2str(lowFrequency) ', ' num2str(highFrequency)]), xlabel('Time (Sec)'), ylabel('Amplitude');
    
	   
	fileName = 'Spectrum Filtered Signal';
	fullFilePath = fullfile(pwd,'Out');
	fullFileName = fullfile(fullFilePath,fileName);
	print(fullFileName,'-djpeg91', '-r180');
%     audiowrite(strcat('Out\specFiltered', num2str(i), '.wav'), filteredSignal, Fs);
		
end
