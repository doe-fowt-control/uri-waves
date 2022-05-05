%% Shawn Albertson 2/8/22

% Uses multiple wave gauges to attempt reconstruction. Creates a plot of
% reconstruction with a full time series indicating where reconstruction 
% took place. Originally created with notions of the prediction zone and 
% frequency selection that have been updated since 2/2/22

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/12.10.21/D.mat'
% load '../data/mat/1.10.22/A.mat'
    % time as `time`
    % wave gauge data as `data`
    % wave guage locations as `x`


[pram, stat] = make_structs;
pram.x = x;


% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(pram, data, time, x);

% Select subset of data for remaining processing
[stat, X, T, eta] = subset(pram, stat, X_, T_, eta_);

% Calculate spectral characteristics and reconstruction frequencies
[w, k, stat] = freq_range(pram, stat, eta, x);

% Find linear weights for reconstruction
[a, b] = linear_weights(X, T, eta, w, k);

% Calculate prediction window
stat = prediction_window(pram, stat, x);

stat.a = a;
stat.b = b;
stat.w = w;
stat.k = k;

% Perform reconstruction at target wave gauge
[slice, t, stat] = reconstruct_slice_ng(pram, stat, X_, T_);


% tb = 2*pi / ((stat.w_hi_pred - stat.w_lo_pred) / (param.nf - 1));
% tb_wl = stat.w_lo_pred;
% tb_c = (1/stat.c_g2) * (max(x) - min(x)) + param.Ta;


pperiod = stat.pperiod;
h_m0 = stat.h_m0;
pg = pram.pg;
np = pram.np;
tr = pram.tr;

% figure
clf
% subplot(2,1,1)
hold on

title('a) Comparison of propagated and measured wave')
xlabel('t / T_{p}')
ylabel('h / H_{s}')

% Generate time series for visualizing the reconstruction
t_vis = (t)/pperiod;
plot(t_vis, slice / h_m0, 'blue')

% shift measured time series back to zero for visualization
plot((T_(:, 1) - pram.tr)/pperiod, eta_(:, pg) / stat.h_m0, 'LineWidth', 3, 'Color', [0,0,0,0.2])

% plot prediction zone boundaries
% xline(stat.zone_lo, 'g-.', 'linewidth', 3)

% plot prediction time
% xline(0, 'r--', 'linewidth', 1)
% 
% xline(stat.zone_hi, 'r-.', 'linewidth', 3)

xlim([-2*pperiod (np-2)*pperiod])
% ylim([-1 1])

% legend('Propagated', 'Measured', 'Calculated prediction zone boundary', 'Reconstruction time', 'location', 'northwest');

% subplot(2,1,2)
% hold on
% plot(time/pperiod, (data(:,1) - mean(data(:,1)))/stat.h_m0, 'Color', [0,0,0,0.7]);
% xline(5/pperiod, 'k-.') % wavemaker on
% xline(pram.tr/pperiod, 'r--', 'LineWidth', 1) % reconstruction time
% rectangle('Position', [(pram.tr/pperiod)-2, -1, (np-2), 2], 'FaceColor', [.1 .1 .1 .1], 'EdgeColor', 'none')
% xline(5/pperiod + 200, 'k-.')
% 
% legend('Raw time series', 'Wavemaker on/off', 'Reconstruction time')
% xlim([0, 300]);
% ylim([-1 1])
% xlabel('t / T_{p}');
% ylabel('h / H_{s}');
% title('b) Full time series of waves at gauge 1 with reconstruction window for a)');








