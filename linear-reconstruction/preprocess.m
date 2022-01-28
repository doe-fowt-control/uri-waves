function [X, T, eta_obs] = preprocess(data, time, x, fs_new, time_start, time_end)
% Trim data before waves fully develop and after waves stop
% Center on mean
% Resample at desired frequency
% Make spatiotemporal instances using meshgrid

% find original sampling frequency (round to integer)
fs_old = round(1/((time(end)-time(1))/numel(time)), 0);

% trim data to inputs in seconds
data = data(time_start * fs_old + 1 : time_end * fs_old, :);
time = time(time_start * fs_old + 1 : time_end * fs_old);

% bring time back to start at zero
time = time - time(1);

% center on mean
data = data - mean(data);

% resample time and observations
eta_obs = data(1: fs_old / fs_new :end, :);
time = time(1: fs_old / fs_new :end);

% spatiotemporal samples
[X, T] = meshgrid(x, time);

