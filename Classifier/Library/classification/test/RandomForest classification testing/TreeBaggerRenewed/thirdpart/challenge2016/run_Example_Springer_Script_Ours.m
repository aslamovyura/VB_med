%% Example Springer script
% A script to demonstrate the use of the Springer segmentation algorithm

%% Copyright (C) 2016  David Springer
% dave.springer@gmail.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%%
clc;
close all;
clear all;

%% Load the default options:
% These options control options such as the original sampling frequency of
% the data, the sampling frequency for the derived features and whether the
% mex code should be used for the Viterbi decoding:
springer_options = default_Springer_HSMM_options;

%% Load the audio data and the annotations:
% These are 6 example PCG recordings, downsampled to 1000 Hz, with
% annotations of the R-peak and end-T-wave positions.
% load('example_data.mat');

signalNames = {'d:\Vibrobox\data_in\101.101.1.wav', ...
           'd:\Vibrobox\data_in\101.103.1.wav', ...
           'd:\Vibrobox\data_in\104.101.1.wav', ...
           'd:\Vibrobox\data_in\109.105.1.3.wav'};
        
j = 0;
example_data = struct('example_audio_data', [], 'example_annotations', []);

for signalName = signalNames
    j = j + 1;
    [signal, Fs] = audioread(signalName{:});
    
    if Fs > 1000
    	decimationFactor = Fs/1000;
    	Fs = 1000;
    	signal = decimate(signal, decimationFactor);
    end
    
    
    example_data.example_audio_data{j} = signal;
end

annotations = xlsread('d:\Vibrobox\annotations.xlsx');

for i=1:j
    
    curColumn = annotations(:,i);
    curColumn = curColumn(~isnan(curColumn));
    curColumn = round(curColumn/(Fs/50));
    example_data.example_annotations{i, 1} = curColumn;
    
    curColumn = annotations(:,i);
    curColumn = curColumn(~isnan(curColumn));
    curColumn = round(curColumn/(Fs/50));
    example_data.example_annotations{i, 2} = curColumn;
end

% Split the data into train and test sets:
% Select the first 5 recordings for training and the sixth for testing:
train_recordings = example_data.example_audio_data([1:3]);
train_annotations = example_data.example_annotations([1:3],:);

test_recordings = example_data.example_audio_data(4);
test_annotations = example_data.example_annotations(4,:);


%% Train the HMM:
[B_matrix, pi_vector, total_obs_distribution] = trainSpringerSegmentationAlgorithm(train_recordings,train_annotations,springer_options.audio_Fs, false);

%% Run the HMM on an unseen test recording:
% And display the resulting segmentation
numPCGs = length(test_recordings);

for PCGi = 1:numPCGs
    [assigned_states] = runSpringerSegmentationAlgorithm(test_recordings{PCGi}, springer_options.audio_Fs, B_matrix, pi_vector, total_obs_distribution, true);
end

