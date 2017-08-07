function abc = decisionMaker(file, config, locs)
abc = []; %unused now, change for normal variable
locsDenoised = locs.waveletDenoising.denoisedPeaks;
locsResidual = locs.waveletDenoising.residualPeaks;
locsSpectrumFilt = locs.spectrumFiltration.peakLocations;
if str2double(config.decisionMaker.Enable)
    signal = file.signal;
    Fs = file.Fs;

    dt = 1/Fs;
    tmax = dt*length(signal);
    t = 0:dt:tmax-dt;
    if str2double(config.decisionMaker.plotsEnable)
        figure, plot(t, signal, 'DisplayName', 'signal');
        hold on;
        plot(t(locsDenoised), signal(locsDenoised), 'r*', 'DisplayName' , 'locsDenoised');
        plot(t(locsResidual), signal(locsResidual), 'g+', 'DisplayName' , 'locsResidual');
        plot(t(locsSpectrumFilt), signal(locsSpectrumFilt), 'ro', 'DisplayName' , 'locsSpectrumFilt');
        title('Original signal with dots on peaks locations for different filtration methods');
        xlabel('Time (sec)');
        ylabel('Amplitude');
        legend('show');
    end
    if str2double(config.decisionMaker.printPlotsEnable)
        fileName = 'Original signal with dots on peaks';
        fullFilePath = fullfile(pwd,'Out');
        fullFileName = fullfile(fullFilePath,fileName);
        print(fullFileName,'-djpeg91', '-r180');
    end 
    
end

end