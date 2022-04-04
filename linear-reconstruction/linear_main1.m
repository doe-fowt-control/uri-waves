%% Shawn Albertson 2/9/22

% Perform reconstruction using a single probe using FFT
% Optionally plot the error between the wave propagation and measurement
% Optionally visualize reconstruction and reconstruction error


% clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/3.21.22/B.mat'

load '../data/mat/3.21.22/cal.mat'

param = struct;
param.fs = 30;          % sampling frequency
param.tr = 130;      % reconstruction time
param.Ta = 15;          % reconstruction assimilation time
param.mu = .15;         % cutoff parameter
param.mg = 1;           % measurement gauges
param.pg = 4;           % gauge to predict at
param.window = 10;       % number of seconds outside of prediction to use for visualization
% spectral parameters
param.ts = 30;           % spectral assimilation time
param.wwindow = [];      % pwelch window
param.noverlap = [];    % pwelch noverlap
param.nfft = 4096;        % pwelch nfft

% calibration
param.slope = cal(1, :);
param.intercept = cal(2,:);


mg = param.mg;
pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;
window = param.window;



stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[t, eta] = preprocess_1g(param, data, time, x);

stat = spectral_1g(param, stat, eta);

% Select subset of data for remaining processing
stat = subset_1g(param, stat, t);

% Find frequency, wavenumber, amplitude, phase
stat = decompose_1g(param, stat, eta);

% % Check that reconstruction worked (create plots)
% check_reconstruction(param, stat, eta)

% Propagate to new space / time region
[r, t_rec, stat] = reconstruct_slice_fft(param, stat, x);

% Unpack time values for prediction window
t_min = stat.t_min;
t_max = stat.t_max;

% Get corresponding measured data
p = eta(stat.i1 - window * fs:stat.i2 + window * fs +1, pg);

figure
% subplot(2,1,1)
hold on
plot(t_rec, r, 'k--', 'linewidth', 2)
plot(t_rec, p, 'b')
xline(t_min, 'k-', 'linewidth', 1)
xline(t_max, 'k-', 'linewidth', 1)
xlim([0 20])
% ylim([-0.06 0.06])
legend('prediction', 'measurement', 'prediction zone')
xlabel('time (s)')
ylabel('amplitude (m)')
title('Wave forecast and measurement')

% subplot(2,1,2)
% plot(t, abs(r-p), 'r')
% xline(t_min, 'k-', 'linewidth', 1)
% xline(t_max, 'k-', 'linewidth', 1)
% % ylim([0 1])
% legend('error', 'prediction zone')
% xlabel('time (s)')
% ylabel('absolute difference')
% title('Error')





