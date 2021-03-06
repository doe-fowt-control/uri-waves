%% Load data
clear

load '../data/mat/12.10.21/D.mat'
% load '../data/mat/1.10.22/A.mat'
    % time as `time`
    % wave gauge data as `data`
    % wave guage locations as `x`

load '../data/noise.mat'
    % pxxn length 513

param = struct;
param.fs = 8;           % sampling frequency
param.tr = 70;          % reconstruction time
param.Ta = 10;          % reconstruction assimilation time
param.ts = param.Ta;    % spectral assimilation time
param.nf = 34;          % number of frequencies used for reconstruction
param.mu = .05;         % cutoff threshold
param.window = [];      % pwelch window
param.noverlap = [];    % pwelch noverlap
param.nfft = [];        % pwelch nfft
param.noise = pxxn;     % example of noisy signal
param.mg = 1:6;         % measurement gauges
param.pg = 7;           % gauge to predict at
param.np = 15;          % number of periods to predict for


% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta_obs] = preprocess(param, data, time, x);

[slice1, t_reconstruct, stat] = linear_wrapper(param, x, X, T, eta_obs);

tb = 2*pi / ((stat.w_hi_pred - stat.w_lo_pred) / (param.nf - 1));
tb_wl = stat.w_lo_pred;
tb_c = (1/stat.c_g2) * (max(x) - min(x)) + param.Ta;

pperiod = stat.pperiod;
pg = param.pg;
np = param.np;

figure
subplot(2,1,1)
hold on

title('a) Comparison of propagated and measured wave')
xlabel('t / T_{p}')
ylabel('h / H_{s}')

% Generate time series for visualizing the reconstruction
t_vis = (t_reconstruct - param.tr)/pperiod;
plot(t_vis, slice1 / stat.h_m0, 'blue')

% shift measured time series back to zero for visualization
plot((T(:, 1) - param.tr)/pperiod, eta_obs(:, pg) / stat.h_m0, 'LineWidth', 3, 'Color', [0,0,0,0.2])

% plot prediction zone boundaries
xline(stat.zone_lo, 'g-.', 'linewidth', 3)

% plot prediction time
xline(0, 'r--', 'linewidth', 1)

xline(stat.zone_hi, 'r-.', 'linewidth', 3)

xlim([-2*pperiod (np-2)*pperiod])
ylim([-1 1])

legend('Propagated', 'Measured', 'Calculated prediction zone boundary', 'Reconstruction time', 'location', 'northwest');

% legend(strcat(num2str(t1), 's input'))
%        strcat(num2str(t2), 's input'), ...
%        strcat(num2str(t3), 's input'))


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








