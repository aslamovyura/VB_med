function segments = springerMethod(file)

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

segments = struct('S1', [], 'S2', [], 'Sys', [], 'Dia' , [], 'RR', []);
                                                
signalLength = length(signal);

prevSampleState = assigned_states(1,1);
tempSegment = signal(1,1);
tempRRSegment = [];
numOfSegs = zeros(1,4);
numOfRRs = 0;

for i=2:signalLength    
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

% add the last chunk
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
