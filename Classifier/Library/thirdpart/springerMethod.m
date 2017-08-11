function segments = springerMethod(file)
% This function takes as input the file structure 
% containing "signal" and "Fs" fields. The Springer segmentation algorithm
% is performed to produce the resulting struct "segments" containing
% the following fields: S1, systole, S2, diastole, RR.
%
% Originally written by David Springer (https://physionet.org/physiotools/hss/)
% Reworked by Ivan Trus, 10.08.2017


%% Load the default options:
% These options control options such as the original sampling frequency of
% the data, the sampling frequency for the derived features and whether the
% mex code should be used for the Viterbi decoding:
springer_options = default_Springer_HSMM_options;

%% Load the audio data and the annotations:
% These are 6 example PCG recordings, downsampled to 1000 Hz, with
% annotations of the R-peak and end-T-wave positions.
load('example_data.mat');

%% Split the data into train and test sets:
% Select the first 5 recordings for training and the sixth for testing:
train_recordings = example_data.example_audio_data([1:5]);
train_annotations = example_data.example_annotations([1:5],:);

Fs = file.Fs;
signal = file.signal;

if Fs > 1000
    decimationFactor = Fs/1000;
    Fs = 1000;
    signal = decimate(signal, decimationFactor);
end

test_recordings = {signal};
test_annotations = example_data.example_annotations(6,:);


%% Train the HMM:
[B_matrix, pi_vector, total_obs_distribution] = trainSpringerSegmentationAlgorithm(train_recordings,train_annotations,Fs, false);

%% Run the HMM on an unseen test recording:
% And display the resulting segmentation
numPCGs = length(test_recordings);

for PCGi = 1:numPCGs
    [assigned_states] = runSpringerSegmentationAlgorithm(test_recordings{PCGi}, springer_options.audio_Fs, B_matrix, pi_vector, total_obs_distribution, true);
end

%% Form the resulting struct which contains S1, S2, systole, diastole and RR
% 
% Written by Ivan Trus on 9th Aug., 2017
% 
% Updated on 10th Aug., 2017:
% reconsidered handling of corner cases:
% now leading and trailing RRs (and their corresponding s1, s2, sys, dia)
% whose lengthes are shorter by more than "thresholdFactor" (25% by default) 
% of the mean length of all other RR segments are removed
%

thresholdFactor = 0.25;

segments = struct('S1', [], 'Sys', [], 'S2', [], 'Dia' , [], 'RR', []);

firstValidIndex = 1;

%ignore leading null states in some signals (e.g. 107.101.1.3)
while assigned_states(firstValidIndex,1) == 0
   firstValidIndex = firstValidIndex+1; 
end
    
prevSampleState = assigned_states(firstValidIndex,1);
tempSegment = signal(firstValidIndex,1);
tempRRSegment = [];
numOfSegs = zeros(1,4);
numOfRRs = 0;
signalLength = length(signal);

for i=firstValidIndex+1:signalLength    
    curSampleState = assigned_states(i,1);
    
    if curSampleState ~= prevSampleState
    
        numOfSegs(1, prevSampleState) = numOfSegs(1, prevSampleState) + 1;
        ind = numOfSegs(1, prevSampleState);
        
        switch prevSampleState
                       
            case 1
                segments.S1{ind} = tempSegment;
            case 2
                segments.Sys{ind} = tempSegment;
            case 3
                segments.S2{ind} = tempSegment;
            case 4    
                segments.Dia{ind} = tempSegment;

        end
        
        tempSegment = [signal(i,1)];
        
        if curSampleState == 1
            numOfRRs = numOfRRs + 1;
            segments.RR{numOfRRs} = tempRRSegment;
                       
            tempRRSegment = [signal(i,1)];
        else
            tempRRSegment = [tempRRSegment signal(i,1)];
        end
     
    else
        tempSegment = [tempSegment signal(i,1)];
        tempRRSegment = [tempRRSegment signal(i,1)];
    end
    
    prevSampleState = curSampleState;
    
end


% calculate threshold length for RR
RRLengthes = zeros(1, numOfRRs-1);
for i=2:numOfRRs
    RRLengthes(1, i) = length(segments.RR{i});
end    

meanRRLength = mean(RRLengthes);
thresholdLength = meanRRLength * thresholdFactor;

% Check the very last RR's length.
% If it satisfies the criteria then add it to the struct as well as
% the last either s1, sys, s3 or dia segment.
% Otherwise the aforementioned ones are not added. 
% Also the segments which have been recently added to the struct 
% and which correspond to the invalid RR are removed from the struct
if abs(length(tempRRSegment)-meanRRLength) < thresholdLength
   
    numOfRRs = numOfRRs + 1;
    segments.RR{numOfRRs} = tempRRSegment;
    
    numOfSegs(1, curSampleState) = numOfSegs(1, curSampleState) + 1;
    ind = numOfSegs(1, curSampleState);

    switch curSampleState

        case 1
            segments.S1{ind} = tempSegment;
        case 2
            segments.Sys{ind} = tempSegment;
        case 3
            segments.S2{ind} = tempSegment;
        case 4    
            segments.Dia{ind} = tempSegment;
    end
    
else
    switch curSampleState
        case 2
            numOfSegs(1,1) = numOfSegs(1,1)-1;
            segments.S1 = segments.S1(1:numOfSegs(1,1));
        case 3
            numOfSegs(1,1) = numOfSegs(1,1)-1;
            segments.S1 = segments.S1(1:numOfSegs(1,1));
            
            numOfSegs(1,2) = numOfSegs(1,2)-1;
            segments.Sys = segments.Sys(1:numOfSegs(1,2));
            
        case 4    
            numOfSegs(1,1) = numOfSegs(1,1)-1;
            segments.S1 = segments.S1(1:numOfSegs(1,1));
            
            numOfSegs(1,2) = numOfSegs(1,2)-1;
            segments.Sys = segments.Sys(1:numOfSegs(1,2));
            
            numOfSegs(1,3) = numOfSegs(1,3)-1;
            segments.S2 = segments.S2(1:numOfSegs(1,3));
    end 
end

% check the very first RR and its corresponding segments
if abs(length(segments.RR{1})-meanRRLength) > thresholdLength
    
    segments.RR = segments.RR(2:numOfRRs);
    numOfRRs = numOfRRs-1;
    
    veryFirstState = assigned_states(firstValidIndex,1);
    
    switch veryFirstState
        
        case 1 
            segments.S1 = segments.S1(2:numOfSegs(1,1));
            segments.Sys = segments.Sys(2:numOfSegs(1,2));
            segments.S2 = segments.S2(2:numOfSegs(1,3));
            segments.Dia = segments.Dia(2:numOfSegs(1,4));
            numOfSegs = numOfSegs-1;
            
        case 2
            segments.Sys = segments.Sys(2:numOfSegs(1,2));
            segments.S2 = segments.S2(2:numOfSegs(1,3));
            segments.Dia = segments.Dia(2:numOfSegs(1,4));
            numOfSegs(1,2:4) = numOfSegs(1,2:4)-1;
        case 3
            segments.S2 = segments.S2(2:numOfSegs(1,3));
            segments.Dia = segments.Dia(2:numOfSegs(1,4));
            numOfSegs(1,3:4) = numOfSegs(1,3:4)-1;     
        case 4    
            segments.Dia = segments.Dia(2:numOfSegs(1,4));
            numOfSegs(1,4) = numOfSegs(1,4)-1;     
    end 
       
end



