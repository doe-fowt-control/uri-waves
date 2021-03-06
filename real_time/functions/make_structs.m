function [pram, stat] = make_structs()
% define parameters here to clean up main file

pram = struct;  % input parameters
stat = struct;  % calculated statistics

% reconstruction parameters
pram.fs = 30;          % sampling frequency
pram.Ta = 15;          % reconstruction assimilation time
pram.mu = .15;         % cutoff parameter
pram.mg = 1;           % measurement gauges
pram.pg = 3;           % prediction gauges
% pram.window = 25;       % number of seconds outside of prediction to use for visualization

% spectral parameters
pram.ts = 20;           % spectral assimilation time
pram.wwindow = [];      % pwelch window
pram.noverlap = [];    % pwelch noverlap
pram.nfft = 4096;        % pwelch nfft

% calibration parameters
% pram.slope = [.1237 .0971 .0946 .1225];
pram.slope = [.1 .1 .1 .1];

% spatial parameters (fixed)
pram.x = [0.0, 0.5, 2.0, 4.0];

% forecast parameters
pram.forecast_length = 2; % seconds; how long to predict for
pram.validation_length = 2; % seconds; how much future wave info to compare with

% buffer parameters
pram.buffer_window = 2; % seconds; how often to grab new data

pram.buffer_size = pram.buffer_window * pram.fs; % samples in new data grab

% length of samples stored on PC at any given moment. Depends on spectral
% assimilation time and validation length
pram.local_buffer_size = (pram.ts + pram.validation_length) * pram.fs;

pram.validation_size = pram.validation_length * pram.fs; % samples to include in validation segment




