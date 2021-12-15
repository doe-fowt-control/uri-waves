%% Load data
clear

load '../data/12.10.21/dataE.mat'
load '../data/12.10.21/timeE.mat'

% time limit for good data
t_lo = 100;
t_hi = 220;

% x locations for gauges
x = [2.934, 2.604, 2.172, 1.632, 0.953, 0, 7.88];

% desired sampling frequency (Hz)
fs = 32;

% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta_obs] = preprocess(dataE, timeE, x, fs, t_lo, t_hi);


% duration = 30; % seconds [ consider converting to number of peak periods? ]
predict_time = 90; % prediction time in seconds
predict_gauge = 7; % gauge to predict at
np = 6; % number of periods to predict for

[slice30, t_reconstruct, pperiod] = doo(50, predict_time, predict_gauge, np, x, fs, X, T, eta_obs);
slice20 = doo(20, predict_time, predict_gauge, np, x, fs, X, T, eta_obs);
slice50 = doo(50, predict_time, predict_gauge, np, x, fs, X, T, eta_obs);

figure
hold on

title('Propagation of Wave D with varying length time inputs used for reconstruction')
xlabel('Time (s)')
ylabel('Amplitude (m)')

plot(t_reconstruct, slice20, 'red')
plot(t_reconstruct, slice30, 'blue')
plot(t_reconstruct, slice50, 'green')
plot(T(:, 1), eta_obs(:, predict_gauge), 'LineWidth', 3, 'Color', [0,0,0,0.2])

xline(predict_time, 'k--')
% xline(predict_time + pperiod, 'k--')
% xline(predict_time + pperiod * 2, 'k--')

xlim([predict_time - 2*pperiod predict_time + np*pperiod])
ylim([-0.05 0.05])

legend('20s input', '30s input', '50s input', 'measured', 'propagation begins')





% % Designate last column as 'test', rest as 'training'
% X_train = X(:, 1:6);
% X_test = X(:, 7);
% T_train = T(:, 1:6);
% T_test = T(:, 7);
% eta_train = eta_obs(:, 1:6);
% eta_test = eta_obs(:, 7);


% pt = predict_time * fs; % index of prediction time
% nt = duration * fs; % number of time samples

% % cutoff value for determining frequency range
% c = 0.01;
% 
% % find 30 frequencies and wavenumbers
% n = 30;
% [w, k] = freq_range(eta_obs(pt-nt:pt, :), fs, c, n);
% 
% % find spectral characteristics
% [m0, h_m0, h_var, pperiod] = spectral(eta_obs, fs);
% 
% % Find linear weights of decomposition
% [a, b] = linear_weights(eta_train, X_train, T_train, pt, nt, w, k);
% 
% % Reconstruct at wave gauge 7
% gauge = 7;
% np = 10; % number of peak periods to reconstruct for
% 
% t_reconstruct = linspace(predict_time, predict_time + np*pperiod, 1000)';
% slice = reconstruct_one_gauge(x, t_reconstruct, k, w, a, b, gauge);










