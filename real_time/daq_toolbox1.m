% 3/25/22 Shawn Albertson
% First iteration on real time data collection / processing. Reads new data at intervals
% defined by buffer_size, and adds it to a constantly changing data array
% local_data_buffer and local_time_buffer. These are made to be global
% variables so they are accessible to the function which runs on every data
% collection (grab_data). The prediction is made for three seconds into the future, but
% there is no data available which can validate the predictions. This will
% be useful when the data needs to be available (rather than validated),
% but for now I need to modify the functions and calls to run on a slightly longer
% delay, comparing the predictions with measurements on a time delay
% determined by forecast_length. Since preprocess, spectral, decompose, and
% reconstruct_slice_fft are the only functions being used I will redefine
% each of these to have the validation accomodation, using suffix_val. 
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
    global pram
    global stat
    global local_data_buffer
    global local_time_buffer
    
    buffer_size = pram.buffer_size;
    x = pram.x;
    
    % function which is done every time buffer is filled
    % grab a bunch of samples, and send them to the workspace
    [data, timestamps, ~] = read(obj, obj.ScansAvailableFcnCount, "OutputFormat", "Matrix");

    local_data_buffer(1:end-buffer_size, :) = local_data_buffer(buffer_size+1:end, :);
    local_data_buffer(end-buffer_size + 1:end, :) = data;
    
    local_time_buffer(1:end-buffer_size, :) = local_time_buffer(buffer_size+1:end, :);
    local_time_buffer(end-buffer_size + 1:end, :) = timestamps;
    
    % Check to see that the buffer has filled
    if local_data_buffer(1) ~= 0
        % get time series starting from zero, scaled and shifted wave data
        [time, eta] = preprocess(pram, local_data_buffer, local_time_buffer);
        
        % spectral analysis on full time series
        stat = spectral(pram, stat, eta);
                  
        stat = decompose(pram, stat, eta);
        
        pram.pg = 3;

        [r, t, stat] = reconstruct_slice_fft(pram, stat, x);

        plot(t, r)
%             
%         % List index of gauges to predict at
%         x_pred = [1,2,3,4];
%         
%         
%         
    end
    
%     assignin('base', 'sample_data', local_data_buffer)
%     assignin('base', 'sample_time', local_time_buffer)
    
%     plot(timestamps, data)
end




% n = 100;
% for i = 1:5
%     scanData = read(d,n);
%     pause(1)
% end

% start(dq, "Duration", seconds(5))
% data = read(dq);
% plot(timestamps, data)