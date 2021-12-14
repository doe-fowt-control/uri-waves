%% Load data
clear

load '../data/12.1.21/data.mat'
load '../data/12.1.21/time.mat'

% time limit for good data
t_lo = 10;
t_hi = 120;

% x locations for gauges
x = [2.934, 2.604, 2.172, 1.632, 0.953, 0];

% desired sampling frequency (Hz)
fs = 32;

% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta_obs] = preprocess(data, time, x, fs, t_lo, t_hi);

% cutoff value for determining frequency range
c = 0.01;

% find 30 frequencies and wavenumbers
n = 30;
[w, k] = freq_range(eta_obs, fs, c, n);

% find spectral characteristics
[m0, h_m0, h_var, pperiod] = spectral(eta_obs, fs);


duration = 30; % seconds [ consider converting to number of peak periods? ]

t = 1; % initial time
nt = 30*fs; % number of time samples

% Find linear weights of decomposition
[a, b] = linear_weights(eta_obs, X, T, t, nt, w, k);

% Reconstruct at wave gauge 1
gauge = 1;
t_reconstruct = T(:, 1);
slice = reconstruct_one_gauge(x, t_reconstruct, k, w, a, b, gauge);

hold on
plot(slice, 'red')
plot(eta_obs(:, gauge), 'blue')
xline(nt)
xline(nt + pperiod * fs)
xline(nt + pperiod * fs * 2)
np = 5; % number of peak periods post data acquisition
xlim([0 nt + pperiod * fs * np])
legend('reconstruction', 'data')

