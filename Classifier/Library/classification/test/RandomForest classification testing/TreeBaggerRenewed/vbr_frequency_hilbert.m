function f = vbr_frequency_hilbert(x, fs, f_range, freq_pulse_length)
	%% Interactive paramenetrs input
	if nargin < 1
		cache_name = [mfilename '_cache.mat'];
		dlg_name = '';
		f_range = [600 750];
		freq_pulse_length = 1;
		if exist(cache_name, 'file')
			load(cache_name);
		end
		
		[dlg_name, dlg_path] = uigetfile({'*.wav','Wave files (*.wav)'}, 'Select file for processing', dlg_name);
		if dlg_name==0
			return
		end
		dlg_name = fullfile(dlg_path,dlg_name);
		[x, fs] = audioread(dlg_name);
		x_name = dlg_name;

		input_arg = inputdlg({'Frequency analysis range (Hz):', 'Filter pulse length (sec.)'}, 'Input parameters', 1, {num2str(f_range) num2str(freq_pulse_length)});
		if isempty(input_arg)
			return
		end
		f_range = str2num(input_arg{1});
		freq_pulse_length = str2double(input_arg{2});

		save(cache_name, 'dlg_name', 'f_range', 'freq_pulse_length');
	else
		x_name = mfilename;
	end
	
	fs2 = fs / 2;
	
	%% Find best carrier frequency
	Fc = find_best_carrier(x, fs, f_range, x_name);
	
	%% Resample data: no need to process unnecessary data
	x_rsmpl_factor = max(1,fs2 / (Fc * 2));
	if x_rsmpl_factor > 1
		[rat_N, rat_D] = rat(x_rsmpl_factor);
		x_rsmpl_factor = rat_N / rat_D;
		x = resample(x, rat_D, rat_N);
		fs = fs / x_rsmpl_factor;
		fs2 = fs / 2;
	end
	
	%% Filter carrier frequency
	freq_order = round(freq_pulse_length * fs2) * 2;
	% b = firls(freq_order, [0 (f_range([1 1 2 2])-mean(f_range)+Fc)/fs2 1], [0 0 1 1 0 0]);
	b = firls(freq_order, [0 (diff(f_range)*[-1 -1 1 1]+Fc)/fs2 1], [0 0 1 1 0 0]);
	b = b(:) .* hamming(length(b));

	grp_delay = fix(length(b)/2);
	xf = fftfilt(b, [x; zeros(grp_delay, size(x,2))]);
	xf(1:grp_delay,:) = [];

	x = abs(hilbert(xf));

	%% Filter envelope
	t = (0:size(x,1)-1)'/fs;
	
	b = firls(freq_order, [0 f_range([1 1 2 2])/fs2 1], [0 0 1 1 0 0]);
	b = b(:) .* hamming(length(b));
	
	grp_delay = fix(length(b)/2);
	xf = fftfilt(b, [x; zeros(grp_delay, size(x,2))]);
	xf(1:grp_delay,:) = [];
	
	h = hilbert(xf);
	f = diff(unwrap(angle(h))) * fs/(2*pi);

	if nargout < 1
		figure('Name',x_name, 'Unit','normalized', 'Position',[0 0 1 1]);
		
		x_lim = t([1 end]);

		subplot(2,1,1);
		plot(t, x);
		xlim(x_lim);
		
		subplot(2,1,2);
		plot(t(1:end-1),f);
		xlim(x_lim);

		set(pan ,'ActionPostCallback',@on_zoom_pan, 'Motion','horizontal');
		set(zoom,'ActionPostCallback',@on_zoom_pan);
		zoom('xon');
		
		clear('f', 't');
	end
end

% Find best carrier frequency
function Fc = find_best_carrier(x, fs, f_range, x_name)
	figure('Name',x_name, 'Units','normalized', 'Position',[0 0 1 1]);

	x_win_ind = 1:min(size(x,1), pow2(nextpow2(fs)));
	xF = fft(x(x_win_ind) .* hamming(length(x_win_ind)), pow2(nextpow2(fs)));
	xF = abs(xF(1:length(xF)/2 + 1)); % power spectrum estimation

	ff = linspace(0,fs/2,length(xF));
	plot(ff,20*log10(xF));
	y_lim = ylim();
	y_lim(1) = quantile(20*log10(xF), 0.02);
	axis([0 fs/2 y_lim]);

	% Smooth power spectrum estimation
	smooth_order = ceil(length(xF) / 1000 / 2) * 2 + 1;
	xF = fftfilt(ones(1,smooth_order)/smooth_order, [xF; zeros(fix(smooth_order/2),1)]);
	xF(1:fix(smooth_order/2)) = [];
	
	hold('on');
	plot(ff,20*log10(xF),'r');
	pan('xon');
	zoom('xon');
	title([x_name ': Power spectrum density'],'Interpreter','none');
	xlabel('Frequency, Hz');
	ylabel('Power, dB');
	legend({'Raw PSD estimation','Smoothed estimation'});
	
	arrayfun(@(x) line(x+[0 0],y_lim,'Color','m'), f_range);

	[~, mi] = max(xF);
	Fc = (mi-1)/(length(xF)-1) * fs/2;
end

function on_zoom_pan(hObject, eventdata) %#ok<INUSD>
%	Usage example:
%	set(pan ,'ActionPostCallback',@on_zoom_pan, 'Motion','horizontal');
%	set(zoom,'ActionPostCallback',@on_zoom_pan);
%	zoom('xon');

	x_lim=xlim();

	data=guidata(hObject);
	if isfield(data,'user_data') && isfield(data.user_data,'x_len')
		rg=x_lim(2)-x_lim(1);
		if x_lim(1)<0
			x_lim=[0 rg];
		end
		if x_lim(2)>data.user_data.x_len
			x_lim=[max(0, data.user_data.x_len-rg) data.user_data.x_len];
		end
	end

	child=get(hObject,'Children');
	set( child( strcmp(get(child,'type'),'axes') & not(strcmp(get(child,'tag'),'legend')) ), 'XLim', x_lim);
end
