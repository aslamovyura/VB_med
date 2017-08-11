function [MFCC] = getMFCCFeatures(segments, parameters)
%% function description
% Function "getMFCCFeatures" calculates MFC coefficients for all 
% elements(S1, Sys, S2, Dia) of every cyle. Then findes the mean 
% value among all cycles
%% ______________initioalization________________________________________%%
num = parameters.numOfMFCC;              %Number of mel filters
Fs = parameters.Fs;
if str2double(parameters.lifterEnable)
    lifter=1:num;                   %Lifter vector index
    lifter=1+floor((num)/2)*(sin(lifter*pi/num));%raised sine lifter version
end
%% ____________calculation______________________________________________%%
for i=1:4
    switch i
        case 1, seg = segments.S1;
        case 2, seg = segments.Sys;
        case 3, seg = segments.S2;
        case 4, seg = segments.Dia;
    end
    FMatrix=zeros(length(seg), num); %Matrix to hold cepstral coefficients
    for j = 1:length(seg)
        frame = seg{j};               %Holds individual frames
        ce1 = sum(frame.^2);          %Frame energy
        ce = log(ce1);
        F = frame'.*hamming(length(frame));%multiplies each frame with hamming window
        FFTo = fft(F);                 %computes the fft
        n = length(FFTo);
        melf = melbankm(num,n,Fs);     %creates 24 filter, mel filter bank
        halfn = 1 + floor(n / 2);    
        spectr = log10(melf * abs(FFTo(1:halfn)).^2);%result is mel-scale filtered
        c = dct(spectr);              %obtains DCT, changes to cepstral domain
        c(1) = ce;                    %replaces first coefficient
        coeffs = c(1:num);            %retains first num coefficients
        if str2double(parameters.lifterEnable)
            ncoeffs = coeffs.*lifter';    %Multiplies coefficients by lifter value
            FMatrix(j,:) = ncoeffs';     %assigns mfcc coeffs to succesive rows i
        end
    end
    switch i
        case 1, MFCC.S1 = mean(FMatrix,1);
        case 2, MFCC.Sys = mean(FMatrix,1);
        case 3, MFCC.S2 = mean(FMatrix,1);
        case 4, MFCC.Dia = mean(FMatrix,1);
    end    
end
end