function [pram, stat] = make_structs

pram = struct;
stat = struct;

% reconstruction parameters
pram.Ta = 15;          % reconstruction assimilation time
pram.nf = 240;           % number of frequencies

pram.mu = .05;         % cutoff parameter (percentage of peak energy)
pram.lam = 0.05;         % regularization parameter

pram.mg = 3:6;           % measurement gauge(s)
pram.pg = 1;           % gauge to predict at

pram.fs = 30;          % sampling frequency
pram.tr = 100;         % reconstruction time

pram.window = 5;       % number of seconds outside of prediction to use for visualization
pram.np = 15;          % number of periods to predict for
pram.pt = pram.tr * pram.fs; % index of prediction time
pram.nt = pram.Ta * pram.fs; % # indices used in reconstruction

% spectral parameters
pram.ts = 30;           % spectral assimilation time
pram.wwindow = [];      % pwelch window
pram.noverlap = [];    % pwelch noverlap
pram.nfft = 4096;        % pwelch nfft



