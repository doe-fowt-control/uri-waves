%% Load data
clear

load '../data/12.10.21/dataC.mat'
load '../data/12.10.21/timeC.mat'

% time limit for good data
t_lo = 15;
t_hi = 120;

% x locations for gauges
x = [2.934, 2.604, 2.172, 1.632, 0.953, 0, 7.88];

% desired sampling frequency (Hz)
fs = 32;



% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta_obs] = preprocess(dataC, timeC, x, fs, t_lo, t_hi);

% Designate last column as 'test', rest as 'training'
X_train = X(:, 1:6);
X_test = X(:, 7);
T_train = T(:, 1:6);
T_test = T(:, 7);
eta_train = eta_obs(:, 1:6);
eta_test = eta_obs(:, 7);

duration = 40; % seconds [ consider converting to number of peak periods? ]
it = 1; % initial time
nt = duration*fs; % number of time samples


% cutoff value for determining frequency range
c = 0.01;

% find 30 frequencies and wavenumbers
n = 30;
[w, k] = freq_range(eta_obs(it:it+nt, :), fs, c, n);

% find spectral characteristics
[m0, h_m0, h_var, pperiod] = spectral(eta_obs, fs);


% Find linear weights of decomposition
[a, b] = linear_weights(eta_train, X_train, T_train, it, nt, w, k);

% Reconstruct at wave gauge 1
gauge = 7;
np = 10; % number of peak periods post data acquisition

t_reconstruct = linspace(duration, duration + np*pperiod)';
slice = reconstruct_one_gauge(x, t_reconstruct, k, w, a, b, gauge);

figure
hold on
plot(t_reconstruct, slice, 'red')
plot(T(:, 1), eta_obs(:, gauge), 'blue')

xline(duration)

% xline(nt + pperiod)
% xline(nt + pperiod * 2)

% xlim([t_lo duration + np/pperiod])
xlim([duration - 3*pperiod duration + np*pperiod])
legend('reconstruction', 'data')

