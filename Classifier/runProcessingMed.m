% run calculations
clc; clear all; clearvars;
close all; 
fclose('all');
Root = fileparts(mfilename('fullpath'));
cd(Root);
add_path

try

	%% _________________ Initialization _____________________________ %%
	
    [file, config] = initializationMed();
        
	%% ________________ Period Detection ____________________________ %%

    % Spectrum filtration 1 tones detection
	peakLocations = [];
    parameters = [];
    parameters.minPeakHeight = config.config.parameters.evaluation.spectrumFiltration.Attributes.minPeakHeight;
    parameters.timePeakDistance = config.config.parameters.evaluation.spectrumFiltration.Attributes.timePeakDistance;  
    parameters.plotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.plotEnable;
    parameters.detailedPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.detailedPlotEnable;
    parameters.printPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.printPlotEnable;
    locs.spectrumFiltration.peakLocations = peakLocations;
    
    % Wavelet denoising periodicity detection
    parameters = [];
    parameters.waveletDenoising.PrintPlotsEnable = config.config.parameters.common.printPlotsEnable.Attributes.value;
    parameters.waveletDenoising.enable = config.config.parameters.common.waveletDenoiseEnable.Attributes.value;
    parameters.waveletDenoising.minPeakDistance = config.config.parameters.evaluation.waveletDenoising.Attributes.minPeakDistance;
    parameters.waveletDenoising.minPeakHeight = config.config.parameters.evaluation.waveletDenoising.Attributes.minPeakHeight;
    parameters.waveletDenoising.deviceType = config.config.parameters.evaluation.waveletDenoising.Attributes.deviceType;
    parameters.waveletDenoising.detailedPlotsEnable = config.config.parameters.evaluation.waveletDenoising.Attributes.detailedPlotsEnable;
    parameters.waveletDenoising.wname = config.config.parameters.evaluation.waveletDenoising.Attributes.wname;
    parameters.waveletDenoising.level = config.config.parameters.evaluation.waveletDenoising.Attributes.level;
    parameters.waveletDenoising.decimationEnable = config.config.parameters.evaluation.waveletDenoising.Attributes.decimationEnable;
    parameters.waveletDenoising.periodicityCalculation.processingEnable = config.config.parameters.evaluation.waveletDenoising.periodicityCalculation.Attributes.processingEnable;
    parameters.waveletDenoising.periodicityCalculation.plotEnable = config.config.parameters.evaluation.waveletDenoising.periodicityCalculation.Attributes.plotEnable;
    
    [denoisedPeaks, residualPeaks] = waveletDenoising(file, parameters);
    denoisedPeaks = [];
    residualPeaks = [];
    
    %plot original signal with locs
    locs.waveletDenoising.denoisedPeaks = denoisedPeaks;
    locs.waveletDenoising.residualPeaks = residualPeaks;
    

	parameters = [];
    parameters.minPeakHeight = config.config.parameters.evaluation.spectrumFiltration.Attributes.minPeakHeight;
    parameters.timePeakDistance = config.config.parameters.evaluation.spectrumFiltration.Attributes.timePeakDistance;  
    parameters.plotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.plotEnable;
    parameters.detailedPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.detailedPlotEnable;
    parameters.printPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.printPlotEnable;
	[peakLocations] = spectrumFiltration(file, parameters);
    


catch
	% Errors checking
end
