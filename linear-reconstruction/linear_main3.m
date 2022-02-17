%% Shawn Albertson
% Published: 2/11/21
% Updated:   2/16/21

% Perform reconstruction using a single probe using FFT
% Evaluate the error between the wave reconstruction and measurement

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'
% load '../data/mat/12.10.21/D.mat'

param = struct;
param.fs = 32;          % sampling frequency
param.tr = 77;          % reconstruction time
param.Ta = 10;          % reconstruction assimilation time
param.mu = .05;         % cutoff threshold
param.mg = 1;           % measurement gauges
param.pg = 1;           % gauge to predict at
param.window = 3;       % number of seconds outside of prediction to use

mg = param.mg;
pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;            % assimilation time (s)
fs = param.fs;
window = param.window;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta] = preprocess(param, data, time, x);

% Try removing entries from full time array
T(1:100, :) = [];

% Select subset of data for remaining processing
[stat] = subset2(param, stat, T);

% Find frequency, wavenumber, amplitude, phase
[stat] = freq_fft(param, stat, eta);

check_reconstruction(param, stat, eta);




