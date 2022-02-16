%% Shawn Albertson
% Published: 2/9/21
% Updated:   2/14/21

% Perform reconstruction using a single probe using FFT
% Evaluate the error between the wave propagation and measurement

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'

param = struct;
param.fs = 32;          % sampling frequency
param.tr = 100;      % reconstruction time
param.Ta = 15;          % reconstruction assimilation time
param.mu = .05;         % cutoff parameter
param.mg = 5;           % measurement gauges
param.pg = 1;           % gauge to predict at
param.window = 10;       % number of seconds outside of prediction to use for visualization

mg = param.mg;
pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;
window = param.window;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(param, data, time, x);

% Try removing entries from full time array
T_(1:100, :) = [];

% Select subset of data for remaining processing
[stat, X, T, eta] = subset(param, stat, X_, T_, eta_);

% Find frequency, wavenumber, amplitude, phase
[w, k, A, phi] = freq_fft(param,eta);

% Check that reconstruction worked (create plots)
check_reconstruction(param, stat, T_, eta_, w, A, phi)

% Propagate to new space / time region
[r, t, stat] = reconstruct_slice_fft(param, stat, X_, T_, w, k, A, phi);

% Unpack time values for prediction window
t_min = stat.t_min;
t_max = stat.t_max;

% Get corresponding measured data
p = eta_(stat.i1 - window * fs:stat.i2 + window * fs +1, pg);

figure
subplot(2,1,1)
hold on
plot(t, r, 'k--', 'linewidth', 2)
plot(t, p, 'b')
xline(t_min, 'g-.')
xline(t_max, 'r-.')
legend('prediction', 'measurement', 'prediction zone')
xlabel('time (s)')
ylabel('amplitude (m)')
title('Wave forecast and measurement')

subplot(2,1,2)
plot(t, (r-p).^2, 'r')
xline(t_min, 'g-.')
xline(t_max, 'r-.')
legend('error', 'prediction zone boundary')
xlabel('time (s)')
ylabel('square difference')
title('Error assessment for simple wave forecast')





