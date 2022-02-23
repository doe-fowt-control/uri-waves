%% Shawn Albertson
% Published: 2/11/21
% Updated:   2/16/21

% Perform reconstruction using a single probe using FFT
% Evaluate the error between the wave reconstruction and measurement

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'
% load '../data/mat/12.10.21/D.mat'

pram = struct;
pram.fs = 32;          % sampling frequency
pram.tr = 77;          % reconstruction time
pram.Ta = 50;          % reconstruction assimilation time
pram.ts = 30;          % spectral assimilation time
pram.mu = .05;         % cutoff threshold
pram.mg = 2:3;           % measurement gauges
pram.pg = 1;           % gauge to predict at
pram.window = 10;       % number of seconds outside of prediction to use
pram.wwindow = [];      % pwelch window
pram.noverlap = [];    % pwelch noverlap
pram.nfft = 4096;        % pwelch nfft

mg = pram.mg;
pg = pram.pg;
tr = pram.tr;            % initial time (s)
Ta = pram.Ta;            % assimilation time (s)
fs = pram.fs;
window = pram.window;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta] = preprocess(pram, data, time, x);

% Try removing entries from full time array
T(1:100, :) = [];

% Select subset of data for remaining processing
[stat] = subset2(pram, stat, T);

% 
stat = spectral(pram, stat, eta);

stat = decompose_reg(pram, stat, X, T, eta);
% stat = decompose(pram, stat, eta);

% % Find frequency, wavenumber, amplitude, phase
% [stat] = freq_fft(param, stat, eta);

check_reconstruction(pram, stat, eta);





