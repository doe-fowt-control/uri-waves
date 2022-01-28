%% Load data
clear

% load '../data/12.10.21/dataD.mat'
load '../data/1.10.22/dataA.mat'
    % time as `time`
    % wave gauge data as `data`
    % wave guage locations as `x`

% time limit for good data
t_lo = 0;
t_hi = 'end';

% desired sampling frequency (Hz)
fs = 32;

% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta_obs] = preprocess(data, time, x, fs, t_lo, t_hi);

predict_time = 90; % prediction time in seconds
predict_gauge = 7; % gauge to predict at
np = 12; % number of periods to predict for

t1 = 15;
% t2 = 17.5;
% t3 = 20;

[slice1, t_reconstruct, stat] = linear_wrapper(t1, predict_time, predict_gauge, np, x, fs, X, T, eta_obs);
% slice2 = doo(t2, predict_time, predict_gauge, np, x, fs, X, T, eta_obs);
% slice3 = doo(t3, predict_time, predict_gauge, np, x, fs, X, T, eta_obs);

pperiod = stat.pperiod;

figure
hold on

title('Comparison of propagated and measured wave')
xlabel('t/Tp')
ylabel('Amplitude (m)')

% Generate time series for visualizing the reconstruction
t_vis = (t_reconstruct - predict_time)/pperiod;
plot(t_vis, slice1, 'blue')
% plot(t_vis, slice2, 'blue')
% plot(t_vis, slice3, 'green')

% shift measured time series back to zero for visualization
plot((T(:, 1) - predict_time)/pperiod, eta_obs(:, predict_gauge), 'LineWidth', 3, 'Color', [0,0,0,0.2])

xline(0, 'k--')
% xline(predict_time + pperiod, 'k--')
% xline(predict_time + pperiod * 2, 'k--')

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








