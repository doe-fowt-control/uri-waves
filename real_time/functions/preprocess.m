function [time, eta] = preprocess(param, data, time)

% Center on mean
% add calibration constants
% fs_new = param.fs;
slope = param.slope;
% intercept = param.intercept;

% bring time back to start at zero
time = time - time(1);

% include calibration curve
data = data .* slope;
% data = data - intercept;

% center on mean
eta = data - mean(data);
