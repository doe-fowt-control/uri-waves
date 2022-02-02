%% Load data
clear

% load '../data/mat/12.10.21/D.mat'
load '../data/mat/1.10.22/A.mat'
    % time as `time`
    % wave gauge data as `data`
    % wave guage locations as `x`

% time limit for good data
t_lo = 0;
t_hi = 'end';

param = struct;
param.fs = 32; % sampling frequency
param.tr = 90; % reconstruction time
param.Ta = 15; % reconstruction assimilation time
param.ts = 15; % spectral assimilation time
param.nf = 30; % number of frequencies used for reconstruction
param.mu = 0.05; % cutoff threshold
param.window = []; % pwelch window
param.noverlap = []; % pwelch noverlap
param.nfft = []; % pwelch nfft

% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta_obs] = preprocess(data, time, x, param.fs, t_lo, t_hi);

predict_gauge = 7;  % gauge to predict at
np = 12;            % number of periods to predict for

[slice1, t_reconstruct, stat] = linear_wrapper(param, predict_gauge, np, x, X, T, eta_obs);

pperiod = stat.pperiod;

figure
hold on

title('Comparison of propagated and measured wave')
xlabel('t/Tp')
ylabel('Amplitude (m)')

% Generate time series for visualizing the reconstruction
t_vis = (t_reconstruct - param.tr)/pperiod;
plot(t_vis, slice1, 'blue')

% shift measured time series back to zero for visualization
plot((T(:, 1) - param.tr)/pperiod, eta_obs(:, predict_gauge), 'LineWidth', 3, 'Color', [0,0,0,0.2])

xline(0, 'k--')


xlim([-2*pperiod (np-2)*pperiod])
ylim([-0.05 0.05])

xline(stat.zone_lo, 'linewidth', 3)
xline(stat.zone_hi, 'linewidth', 3)

legend('propagated','measured');

% legend(strcat(num2str(t1), 's input'))
%        strcat(num2str(t2), 's input'), ...
%        strcat(num2str(t3), 's input'))


% clf;
% hold on
% plot(time/pperiod, (data(:,1) - mean(data(:,1)))/stat.h_m0, 'Color', [0,0,0,0.7]);
% xline(5/pperiod, 'r--')
% xline(5/pperiod + 200, 'r--')
% xlim([0, 300]);
% xlabel('t/Tp');
% ylabel('h/Hs');
% title('Example time series of full wave generation process');








