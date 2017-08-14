%UNUSED
clc;
clear all;
close all;

[signal, Fs] = audioread('C:\Медпроект\Original Signals\107.101.1.3.wav'); 
signal = signal(:,1);
file.signal = signal;
file.Fs = Fs;
signalLength = length(signal);

dt = 1/Fs;
tmax = dt*signalLength;
t = 0:dt:tmax-dt;

h = figure 
plot(t,signal), title('Signal');
xlabel('Time (Sec)');
ylabel('Signal');
hold on;

% [filteredSignal] = spectrumFiltration(file, t);
% figure;
% plot(t,filteredSignal), title('filteredSignal');
% xlabel('Time (Sec)');
% ylabel('filteredSignal');
% hold on;

%% ========================= Entropy of Energy Calculation ============= %%
winLength = 0.15; %in seconds
winStep = 0.01; %in seconds
numOfShortBlocks = 5;

[Entropy] = energyEntropyBlock(signal,winLength*Fs,winStep*Fs,numOfShortBlocks);

entropySize = length(Entropy);

% dtEnt = dt * signalLength / entropySize;
% tEnt = 0:dtEnt:tmax-dtEnt;

dtEnt = winStep;
leadingTrailingSpace = winLength/2;
tEnt = leadingTrailingSpace:dtEnt:tmax-leadingTrailingSpace;

plot(tEnt, Entropy, 'r');  


%% =================== Finding pattern - na?ve approach ================ %%
cutoffLevel = 0.1;

isToneBegun = 0;
dtEntToDt = dtEnt / dt;


% try
%     load('tones.mat');
%     numOfTones = size(tones, 2);
% catch
    tones = [];
    numOfTones = 1;
% end


tStart = 0;
tEnd = 0;

for i = 1:entropySize
    
    curEntropy = Entropy(i);
    if curEntropy > cutoffLevel
        
        if ~isToneBegun 
            
            isToneBegun = 1;
            tStart = i * dtEntToDt;
            startIndex = round(tStart);
            
        end
    else
        if isToneBegun
            
%            tEnd  = i * dtEntToDt;

           tEnd = startIndex + 2*winLength*Fs;

           endIndex = round(tEnd);
           
           
           [pk, lc] = findpeaks(signal(startIndex : endIndex), (startIndex : endIndex), 'MinPeakDistance', 2*winLength*Fs - 1 ,'Npeaks', 1);
           figure, plot ( (lc - winLength*Fs : lc + winLength*Fs), signal(lc - winLength*Fs : lc + winLength*Fs), lc, pk, '-r*' );       
           
           tones = [tones signal(lc - winLength*Fs : lc + winLength*Fs)];           
           numOfTones = numOfTones + 1;
           isToneBegun = 0;
                      
        end
    end
end


% save('tones.mat', 'tones', '-mat');

tones = tones';

% plot all the extracted tones
figure;
for i = 1:numOfTones-1
    plot(tones(i,:));
    hold on;
end
title('Extracted Tones');

% compute mean value of tones
% meanValueOfTones = sum(tones) / (numOfTones - 1);
meanValueOfTones = [];
sumOfTones = zeros(length(tones));
for i = 1:2:length(tones(:,1))
    sumOfTones = sumOfTones + tones(i, :);
end
meanValueOfTones = sumOfTones/(length(tones(:,1))/2);
figure, plot(meanValueOfTones,'b'), title('Mean Value of Tones (Resulted Pattern)');

	fileName = 'Mean Value of SIGNAL Tones (Resulted Pattern)';
	fullFilePath = fullfile(pwd,'Out');
	fullFileName = fullfile(fullFilePath,fileName);
	print(fullFileName,'-djpeg91', '-r180');

% Taken from https://www.mathworks.com/matlabcentral/fileexchange/19236-some-basic-audio-features    
function [Entropy] = energyEntropyBlock(f,winLength,winStep,numOfShortBlocks)
f = f / max(abs(f));
Eol = sum(f.^2);
L = length(f);

if (winLength==0)
    winLength = floor(L);
    winStep = floor(L);
end


numOfBlocks = (L-winLength)/winStep + 1;
curPos = 1;
for (i=1:numOfBlocks)
    curBlock = f(curPos:curPos+winLength-1);
    for (j=1:numOfShortBlocks)        
        s(j) = sum(curBlock((j-1)*(winLength/numOfShortBlocks)+1:j*(winLength/numOfShortBlocks)).^2)/Eol;
    end
    
    Entropy(i) = -sum(s.*log2(s));
    curPos = curPos + winStep;
end

end    


function [filteredSignal] = spectrumFiltration(file, t)

    lowFrequency = 20;
    highFrequency = 60;

	Fs = file.Fs;
	spec = fft(file.signal);
	df = file.Fs/ length(file.signal);

% cutting off stop band

	f = 0:df:Fs-df;
	f_valid = (f > lowFrequency) & (f < highFrequency);
	spec_valid = spec;
	spec_valid(~f_valid) = 0;
	filteredSignal = ifft(spec_valid,'symmetric');
       
%     findpeaks(filteredSignal, t, 'MinPeakHeight',0.05,'MinPeakDistance',0.73);
%     title([ 'spectrum filterd signal in low - high freq: ' num2str(lowFrequency) ', ' num2str(highFrequency)]), xlabel('Time (Sec)'), ylabel('Amplitude');
    
		
end
    
    
