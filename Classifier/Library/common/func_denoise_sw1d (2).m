function [sigDEN_r, wDEC_r, wDEC_nonFiltered_r] = func_denoise_sw1d(SIG, signalLength, Fs, deviceType)
% FUNC_DENOISE_SW1D Saved Denoising Process.
%   SIG: vector of data
%   -------------------
%   sigDEN: vector of denoised data
%   wDEC: stationary wavelet decomposition

%  Auto-generated by Wavelet Toolbox on 14-Jul-2017 14:54:08

% Analysis parameters.
%---------------------
wname = 'sym7';
if deviceType == '1'
    level = 5;
elseif deviceType == '2'
    level = 10;
else
    disp('ERROR! Wrong device!');
    return;
end


% meth = 'sqtwolog';
% scal_OR_alfa = one;



% adding trailing zeros to satisfy needed signal length requirement
multiplicityFactor = 2^level;
neededSignalLength = ceil(signalLength/multiplicityFactor) * multiplicityFactor;

if (neededSignalLength > signalLength)
    numOfAddedSamples = neededSignalLength - signalLength;
    SIG = [SIG; zeros(numOfAddedSamples, 1)];
end




%% Decompose using SWT.
%---------------------
wDEC = swt(SIG,level,wname);
wDEC_nonFiltered = wDEC;
wDECSize = size(wDEC);
wDECNumbers = wDECSize(1);


%% ===================== Denoising parameters. ============================%%
%----------------------
sorh = 'h';    % Specified soft or hard thresholding

%% ================== Setting noise treshold level ========================%%

for k = 1:wDECNumbers
    
    [noiseSTD(k)] = getNoiseSignalTroughEntropy(wDEC(k, :), Fs, deviceType);
    
    currentSignal = wDEC(k, :);
    
    noiseTreshold(k) = noiseSTD(k)*sqrt(2*log(length(currentSignal)));

end


thrSettings =  {...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 1)   max(wDEC(1, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 2)   max(wDEC(2, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 3)   max(wDEC(3, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 4)   max(wDEC(4, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 5)   max(wDEC(5, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 6)   max(wDEC(6, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 7)   max(wDEC(7, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 8)   max(wDEC(8, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 9)   max(wDEC(9, :)); ...
    ]; ...
    [...
    1.000000000000000  signalLength      noiseTreshold(1, 10)   max(wDEC(10, :)); ...
    ]; ...
    };


%% Denoise.
%---------
len = length(SIG);
for k = 1:level
    thr_par = thrSettings{k};
%     thr_par = thselect(wDEC(k),'sqtwolog');
    if ~isempty(thr_par)
        NB_int = size(thr_par,1);
        x      = [thr_par(:,1) ; thr_par(NB_int,2)];
        x      = round(x);
        x(x<1) = 1;
        x(x>len) = len;
        thr1 = thr_par(:,3);
        thr2 = thr_par(:,4);
        for j = 1:NB_int
            if j==1 , d_beg = 0; else d_beg = 1; end
            j_beg = x(j)+d_beg;
            j_end = x(j+1);
            j_ind = (j_beg:j_end);
            wDEC(k,j_ind) = wthresh(wDEC(k,j_ind),sorh,thr1(j));
%             wDEC(k,j_ind) = wthresh_our(wDEC(k,j_ind),sorh,thr1(j),thr2(j));              %Filter in range
           
        end
        [~, ~, validityFlag(k)] = windowKurtosis(wDEC(k, :), Fs);
    end
end

%% Reconstruct the denoise signal using ISWT.
%-------------------------------------------
j = 1;
for i = 1:level
    if validityFlag(i) == 1
        wDECValid(j, :) = wDEC(i, :);
        j = j + 1;
    else 
        disp('ERROR! No valid levels');
        wDECValid = wDEC(i, :);                                             %Added for phone when no valid levels
    end
end

if all(validityFlag) == 0
        disp('Reconstructing signal through all filtered coefficients');
end
    
    sigDEN = iswt(wDECValid,wname);
    
    


%returned values
sigDEN_r = sigDEN(1:signalLength);
wDEC_r = wDEC(:,1:signalLength);
wDEC_nonFiltered_r = wDEC_nonFiltered(:,1:signalLength);

end


function [resultedNoiseSTD] = getNoiseSignalTroughEntropy(signal, Fs, deviceType)
    winLength = 0.10; %in seconds
    winStep = 0.01; %in seconds
    numOfShortBlocks = 5;
    
    signalLength = length(signal);
    dt = 1/Fs;
    tmax = dt*signalLength;
    t = 0:dt:tmax-dt;
    
    Entropy = [];
    [Entropy] = energyEntropyBlock(signal,winLength*Fs,winStep*Fs,numOfShortBlocks);

    entropySize = length(Entropy);

    % dtEnt = dt * signalLength / entropySize;
    % tEnt = 0:dtEnt:tmax-dtEnt;

    dtEnt = winStep;
    leadingTrailingSpace = winLength/2;
    tEnt = leadingTrailingSpace:dtEnt:tmax-leadingTrailingSpace;

%     plot(tEnt, Entropy, 'r');



    %% =================== Finding Standard Deviation of Noise ================ %%
    switch deviceType
        case '1'
            cutoffLevel = 0.01;
        case '2'
            cutoffLevel = 0.001;
    end
    isNoiseBegun = 0;
    dtEntToDt = dtEnt / dt;

    noiseExcerpts = {};
    numOfNoiseExcerpts = 1;

    tStart = 0;
    tEnd = 0;
    
    for i = 1:entropySize

        curEntropy = Entropy(i);
        if curEntropy < cutoffLevel

            if ~isNoiseBegun 

                isNoiseBegun = 1;
                tStart = i * dtEntToDt;
                startIndex = round(tStart);

            end
        else
            if isNoiseBegun

               tEnd  = i * dtEntToDt;

               endIndex = round(tEnd);

               noiseExcerpts{numOfNoiseExcerpts} = signal(startIndex : endIndex);           
               numOfNoiseExcerpts = numOfNoiseExcerpts + 1;
               isNoiseBegun = 0;

            end
        end
    end

    noiseExcerpts = noiseExcerpts';

    % plot all the extracted noise excerpts
%     for i = 1:numOfNoiseExcerpts-1
%         figure, plot(noiseExcerpts{i});
%     end
%     title('Extracted Noise Excerpts');

    % noise STD calculation
    if numOfNoiseExcerpts>1
        summarizedSTD = 0;
        for i = 1:numOfNoiseExcerpts-1
            noiseSTD = std(noiseExcerpts{i});
            summarizedSTD = summarizedSTD + noiseSTD;
        end
        resultedNoiseSTD = summarizedSTD / (numOfNoiseExcerpts-1);
    else
        resultedNoiseSTD = 0;
    end
end

function [Entropy] = energyEntropyBlock(f,winLength,winStep,numOfShortBlocks)

Entropy = [];
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
