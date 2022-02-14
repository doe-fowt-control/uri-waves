%% Shawn Albertson
% Published: 2/8/21
% Updated:   2/14/21

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/12.10.21/D.mat'
% load '../data/mat/1.10.22/A.mat'
    % time as `time`
    % wave gauge data as `data`
    % wave guage locations as `x`

load '../data/noise.mat'
    % pxxn length 513

param = struct;
param.fs = 32;          % sampling frequency
param.tr = 71;          % reconstruction time
param.Ta = 15;          % reconstruction assimilation time
param.nf = 30;          % number of frequencies used for reconstruction
param.mu = .05;         % cutoff threshold
param.window = [];      % pwelch window
param.noverlap = [];    % pwelch noverlap
param.nfft = [];        % pwelch nfft
param.noise = pxxn;     % example of noisy signal
param.mg = 1:6;         % measurement gauges
param.pg = 7;           % gauge to predict at
param.np = 15;          % number of periods to predict for
param.pt = param.tr * param.fs; % index of prediction time
param.nt = param.Ta * param.fs; % # indices used in reconstruction

% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(param, data, time, x);

% Select subset of data for remaining processing
[param, X, T, eta] = subset(param, X_, T_, eta_);

% Calculate spectral characteristics and reconstruction frequencies
[w, k, stat] = freq_range(param, eta);

% Find linear weights for reconstruction
[a, b] = linear_weights(X, T, eta, w, k);

% Calculate prediction window
stat = prediction_window(param, stat, x);

% Perform reconstruction at target wave gauge
[slice, t] = reconstruct_slice(param, X_, T_, a, b, w, k);


% tb = 2*pi / ((stat.w_hi_pred - stat.w_lo_pred) / (param.nf - 1));
% tb_wl = stat.w_lo_pred;
% tb_c = (1/stat.c_g2) * (max(x) - min(x)) + param.Ta;


pperiod = stat.pperiod;
h_m0 = stat.h_m0;
pg = param.pg;
np = param.np;
tr = param.tr;

figure
subplot(2,1,1)
hold on

title('a) Comparison of propagated and measured wave')
xlabel('t / T_{p}')
ylabel('h / H_{s}')

% Generate time series for visualizing the reconstruction
t_vis = (t - tr)/pperiod;
plot(t_vis, slice / h_m0, 'blue')

% shift measured time series back to zero for visualization
plot((T_(:, 1) - param.tr)/pperiod, eta_(:, pg) / stat.h_m0, 'LineWidth', 3, 'Color', [0,0,0,0.2])

% plot prediction zone boundaries
xline(stat.zone_lo, 'g-.', 'linewidth', 3)

% plot prediction time
xline(0, 'r--', 'linewidth', 1)

xline(stat.zone_hi, 'r-.', 'linewidth', 3)

xlim([-2*pperiod (np-2)*pperiod])
ylim([-1 1])

legend('Propagated', 'Measured', 'Calculated prediction zone boundary', 'Reconstruction time', 'location', 'northwest');

subplot(2,1,2)
hold on
plot(time/pperiod, (data(:,1) - mean(data(:,1)))/stat.h_m0, 'Color', [0,0,0,0.7]);
xline(5/pperiod, 'k-.') % wavemaker on
xline(param.tr/pperiod, 'r--', 'LineWidth', 1) % reconstruction time
rectangle('Position', [(param.tr/pperiod)-2, -1, (np-2), 2], 'FaceColor', [.1 .1 .1 .1], 'EdgeColor', 'none')
xline(5/pperiod + 200, 'k-.')

legend('Raw time series', 'Wavemaker on/off', 'Reconstruction time')
xlim([0, 300]);
ylim([-1 1])
xlabel('t / T_{p}');
ylabel('h / H_{s}');
title('b) Full time series of waves at gauge 1 with reconstruction window for a)');








