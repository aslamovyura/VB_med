% run calculations
clc;  clearvars;
clear all;
close all; 
fclose('all');
Root = fileparts(mfilename('fullpath'));
cd(Root);
add_path

% try

	%% _________________ Initialization _____________________________ %%
	
    [file, config] = initializationMed();
        
	%% ________________ Period Detection ____________________________ %%
    
    %currently unused
    
%     % Spectrum filtration 1 tones detection
% 	peakLocations = [];
%     parameters = [];
%     parameters.minPeakHeight = config.config.parameters.evaluation.spectrumFiltration.Attributes.minPeakHeight;
%     parameters.timePeakDistance = config.config.parameters.evaluation.spectrumFiltration.Attributes.timePeakDistance;  
%     parameters.plotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.plotEnable;
%     parameters.detailedPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.detailedPlotEnable;
%     parameters.printPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.printPlotEnable;
%     
%     
%     % Wavelet denoising periodicity detection
%     parameters = [];
%     parameters.waveletDenoising.printPlotsEnable = config.config.parameters.common.printPlotsEnable.Attributes.value;
%     parameters.waveletDenoising.enable = config.config.parameters.common.waveletDenoiseEnable.Attributes.value;
%     parameters.waveletDenoising.plotsEnable = config.config.parameters.evaluation.waveletDenoising.Attributes.plotsEnable;
%     parameters.waveletDenoising.minPeakDistance = config.config.parameters.evaluation.waveletDenoising.Attributes.minPeakDistance;
%     parameters.waveletDenoising.minPeakHeight = config.config.parameters.evaluation.waveletDenoising.Attributes.minPeakHeight;
%     parameters.waveletDenoising.deviceType = config.config.parameters.evaluation.waveletDenoising.Attributes.deviceType;
%     parameters.waveletDenoising.detailedPlotsEnable = config.config.parameters.evaluation.waveletDenoising.Attributes.detailedPlotsEnable;
%     parameters.waveletDenoising.wname = config.config.parameters.evaluation.waveletDenoising.Attributes.wname;
%     parameters.waveletDenoising.level = config.config.parameters.evaluation.waveletDenoising.Attributes.level;
%     parameters.waveletDenoising.periodicityCalculation.processingEnable = config.config.parameters.evaluation.waveletDenoising.periodicityCalculation.Attributes.processingEnable;
%     parameters.waveletDenoising.periodicityCalculation.plotsEnable = config.config.parameters.evaluation.waveletDenoising.periodicityCalculation.Attributes.plotsEnable;
%     
%     denoisedPeaks = [];
%     residualPeaks = [];
%     waveletDenoisingResult = waveletDenoising(file, parameters);
%     
%     
%     
%     
% 
% 	parameters = [];
%     parameters.minPeakHeight = config.config.parameters.evaluation.spectrumFiltration.Attributes.minPeakHeight;
%     parameters.timePeakDistance = config.config.parameters.evaluation.spectrumFiltration.Attributes.timePeakDistance;  
%     parameters.plotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.plotEnable;
%     parameters.detailedPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.detailedPlotEnable;
%     parameters.printPlotEnable = config.config.parameters.evaluation.spectrumFiltration.Attributes.printPlotEnable;
% 	[peakLocations] = spectrumFiltration(file, parameters);
%     
%     %plot original signal with locs
%     locs.waveletDenoising.denoisedPeaks = waveletDenoisingResult.denoisedSignal.locsSamples;
%     locs.waveletDenoising.residualPeaks = waveletDenoisingResult.residualSignal.locsSamples;
%     locs.spectrumFiltration.peakLocations = peakLocations;
    
    %% ________________ Decision Maker ____________________________ %%
    %wrong, unused
%     parameters = [];
%     parameters.decisionMaker.printPlotsEnable = config.config.parameters.common.printPlotsEnable.Attributes.value;
%     parameters.decisionMaker.Enable = config.config.parameters.common.decisionMaker.Attributes.value;
%     parameters.decisionMaker.plotsEnable = config.config.parameters.evaluation.decisionMaker.Attributes.plotsEnable;
%     abc = decisionMaker(file, parameters, locs);


%%________________ Springer's method ____________________________ %%

    signalSegments = springerMethod(file); 
    %%
    parameters = [];
    parameters.classification.printPlotsEnable = config.config.parameters.common.printPlotsEnable.Attributes.value;
    parameters.classification.enable = config.config.parameters.common.classification.Attributes.value;
    parameters.timeDomain.intervalLengthes = config.config.parameters.evaluation.timeDomainFeatures.intervalLengthes.Attributes.processingEnable;
    parameters.timeDomain.intervalRatios = config.config.parameters.evaluation.timeDomainFeatures.intervalRatios.Attributes.processingEnable;
    parameters.timeDomain.meanAmplitudesRatios = config.config.parameters.evaluation.timeDomainFeatures.meanAmplitudesRatios.Attributes.processingEnable;
    parameters.timeDomain.kurtosis = config.config.parameters.evaluation.timeDomainFeatures.kurtosis.Attributes.processingEnable;
    parameters.timeDomain.skewness = config.config.parameters.evaluation.timeDomainFeatures.skewness.Attributes.processingEnable;
    parameters.frequencyDomain.powerSpectrum = config.config.parameters.evaluation.frequencyDomainFeatures.powerSpectrum.Attributes.processingEnable;
    parameters.frequencyDomain.MFCC = config.config.parameters.evaluation.frequencyDomainFeatures.MFCC.Attributes.processingEnable;

    features = featuresExtraction(signalSegments, file, parameters);
% catch 

% 	Errors checking
% end
