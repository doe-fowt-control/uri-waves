function [X, T, t, eta] = preprocess_ng(param, data, time, x)
% Trim data before waves fully develop and after waves stop
% Center on mean
% Resample at desired frequency
% Make spatiotemporal instances using meshgrid

fs_new = param.fs;

% find original sampling frequency (round to integer)
fs_old = round(1/((time(end)-time(1))/numel(time)), 0);

% bring time back to start at zero
time = time - time(1);

% include calibration curve
if exist('param.slope', 'var')
    data = data .* param.slope;
end

if exist('param.intercept', 'var')
    data = data - param.intercept;
end

% center on mean
data = data - mean(data);

% resample time and observations
eta = data(1: fs_old / fs_new :end, :);
t = time(1: fs_old / fs_new :end);

% spatiotemporal samples
[X, T] = meshgrid(x, t);

