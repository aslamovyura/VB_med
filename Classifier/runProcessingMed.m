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
