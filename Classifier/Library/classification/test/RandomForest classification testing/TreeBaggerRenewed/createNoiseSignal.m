clear all;
% close all;
clc;

FILENAME = 'D:\Учеба\Diploma\Диплом\libsvm v1.2\dataset\train\On\75.rawdata.wav';
[y Fs] = audioread(FILENAME);

channel = 1;
y = y(:, channel);
len = length(y);
y_noise = awgn(y, 2.5, 'measured');

y_new = y + y_noise;

audiowrite('05.wav', y_new, Fs);

% figure, plot(y);
% figure, plot(y_new);


FILENAME = 'D:\A.Bourak\Diploma SVM\libsvm v1.2\dataset\train\Smesitel\1857.rawdata.wav';
[y Fs] = audioread(FILENAME);

channel = 1;
y = y(:, channel);
len = length(y);
y_noise = awgn(y, 10, 'measured');

y_new = y + y_noise;

audiowrite('s1857.rawdata_noise_10.wav', y_new, Fs);


FILENAME = 'D:\A.Bourak\Diploma SVM\libsvm v1.2\dataset\train\Smesitel\1857.rawdata.wav';
[y Fs] = audioread(FILENAME);

channel = 1;
y = y(:, channel);
len = length(y);
y_noise = awgn(y, 5, 'measured');

y_new = y + y_noise;

audiowrite('s1857.rawdata_noise_5.wav', y_new, Fs);

FILENAME = 'D:\A.Bourak\Diploma SVM\libsvm v1.2\dataset\train\Smesitel\1857.rawdata.wav';
[y Fs] = audioread(FILENAME);

channel = 1;
y = y(:, channel);
len = length(y);
y_noise = awgn(y, 2.5, 'measured');

y_new = y + y_noise;

audiowrite('s1857.rawdata_noise_25.wav', y_new, Fs);