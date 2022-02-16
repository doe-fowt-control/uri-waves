%% Shawn Albertson
% Published: 2/9/21
% Updated:   2/14/21

% Perform reconstruction using a single probe using FFT
% Evaluate the error between the wave propagation and measurement across
% full time series

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'

param = struct;
param.fs = 32;          % sampling frequency
param.Ta = 15;          % reconstruction assimilation time
param.mu = .05;         % cutoff threshold
param.mg = 4;           % measurement gauge
param.pg = 1;           % gauge to predict at
param.window = 5;       % number of seconds outside of prediction to use

% Calculate prediction zone using one probe and fourier transform

mg = param.mg;
pg = param.pg;
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;
window = param.window;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(param, data, time, x);

t_list = T_(40*fs:100*fs, 1);
e_list = ones(length(t_list), 1);

for ti = 1:1:length(t_list)

    param.tr = t_list(ti);
    param.pt = round(param.tr * param.fs); % index of prediction time
    
    % Select subset of data for remaining processing
    [stat, X, T, eta] = subset(param, stat, X_, T_, eta_);
    
    % Find frequency, wavenumber, amplitude, phase
    [w, k, A, phi] = freq_fft(param, eta);
    
    % Reconstruct at perscribed time window
    [r, t, stat] = reconstruct_slice_fft(param, stat, X_, T_, w, k, A, phi);
    
    % Unpack time values for prediction window
    t_min = stat.t_min;
    t_max = stat.t_max;
    
    % Get corresponding measured data
    p = eta_(stat.i1 - window * fs: stat.i2 + window * fs + 1)';
    
    % Normalized root mean square error
    e = rmse(r, p, stat);

    e_list(ti) = e;
end

plot(t_list, e_list)
xlabel('time (s)')
ylabel('rmse')
title('evolution of rms error over time')
