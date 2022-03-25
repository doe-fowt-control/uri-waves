% 3/25/22 Shawn Albertson
% Adds a validation component to the wave measurement and
% prediction in real time. It does this by extending the local_data_buffer
% by some validation length, and performs the
% decomposition/reconstruction using an offset from the end of the signal
% dependent on the length of desired validation.

clear
addpath 'C:\Users\Wavetank\Desktop\DoE FOWT\Wave Gauges\real_time\functions'

% make the big boys global. 2 structs, 2 buffers
global pram
global stat
global local_data_buffer
global local_time_buffer

% initialize structs
[pram, stat] = make_structs;

% pull key values (values used in the main script) from the struct objects
fs = pram.fs; % sampling rate
buffer_size = pram.buffer_size; % number of samples to move from device at a time
local_buffer_size = pram.local_buffer_size; % number of samples to hold in workspace
x = pram.x; % wave gauge positions

% make empty arrays for filling with data
local_data_buffer = zeros(local_buffer_size, length(x));
local_time_buffer = zeros(local_buffer_size, 1);

% initialize DataAcquisition object (see matlab Data Acquisition Toolbox
% documentation). Define sampling rate
d = daq("ni");
d.Rate = fs;

% add channels to DataAcquisition object
a0 = addinput(d, "PXI1Slot5", "ai0", "Voltage");
a2 = addinput(d, "PXI1Slot5", "ai2", "Voltage");
a4 = addinput(d, "PXI1Slot5", "ai4", "Voltage");
a6 = addinput(d, "PXI1Slot5", "ai6", "Voltage");

% point to function which should be done every time buffer is filled
d.ScansAvailableFcn = @grab_data;

% define size of the buffer (number of samples to require to fill)
d.ScansAvailableFcnCount = buffer_size;

% start continuous data acquisition
start(d, "Continuous")

% plot(sample_time, sample_data)
function grab_data(obj, ~)
    % import globals
    global pram
    global stat
    global local_data_buffer
    global local_time_buffer
    
    x = pram.x;
    
    % function which is done every time buffer is filled
    % grab a bunch of samples, and send them to the workspace
    [data, timestamps, ~] = read(obj, obj.ScansAvailableFcnCount, "OutputFormat", "Matrix");

    local_data_buffer = update_buffer(pram, local_data_buffer, data);
    local_time_buffer = update_buffer(pram, local_time_buffer, timestamps);
    
    % Check to see that the buffer has filled
    if local_data_buffer(1) ~= 0
        % get time series starting from zero, scaled and shifted wave data
        [time, eta] = preprocess(pram, local_data_buffer, local_time_buffer);
        
        % spectral analysis on full time series
        stat = spectral(pram, stat, eta);
        
        % find amplitudes, phases, wavenumbers, frequencies
        stat = decompose(pram, stat, eta);

        % reconstruct for future time
        [r, t, stat] = reconstruct_slice_fft(pram, stat, x);

        % find measurements from gauge at validation interval
        [pval, tval] = get_validation(pram, time, eta);
%         assignin('base', 'sample_data', pval)
%         assignin('base', 'sample_time', tval)          
        
        clf
        hold on
        plot(t, r)
        plot(tval, pval)
        legend('prediction', 'measurement')
        xlabel('time (s)')
        ylabel('amplitude (m)')
        title('Real time data acquisition and measurement comparison')
   
    
    end
    
end

