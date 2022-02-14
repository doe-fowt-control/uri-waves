%% Shawn Albertson
% Published: 2/11/21
% Updated:   2/14/21

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
param.pt = param.tr * param.fs + 1; % index of prediction time
param.nt = param.Ta * param.fs; % # indices used in reconstruction
param.window = 3;              % number of seconds outside of prediction to use

mg = param.mg;
pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;
pt = param.pt;
nt = param.nt;
window = param.window;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(param, data, time, x);

% Try removing entries from full time array
T_(1:100, :) = [];

% Select subset of data for remaining processing
[stat, X, T, eta] = subset(param, stat, X_, T_, eta_);

% Find frequency, wavenumber, amplitude, phase
[w, k, A, phi] = freq_fft(param, eta);

check_reconstruction(param, stat, T_, eta_, w, A, phi);





