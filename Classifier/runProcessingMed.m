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
	
	[peakLocations] = spectrumFiltration(file, config);

catch
	% Errors checking
end
