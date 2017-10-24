function result = tr_obs_diastoleMFCC(segments, config, info)

    seg = segments.diastole;
    num = 13;              %Number of mel filters
    Fs = 1000;
    %Use?
    lifter=1:num;                   %Lifter vector index
    lifter=1+floor((num)/2)*(sin(lifter*pi/num));%raised sine lifter version
    
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
        
            ncoeffs = coeffs.*lifter';    %Multiplies coefficients by lifter value
            FMatrix(j,:) = ncoeffs';     %assigns mfcc coeffs to succesive rows i
        
    end
    
    result = median(FMatrix, 1);

end
