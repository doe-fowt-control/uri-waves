function [slice, t_reconstruct, stat] = linear_wrapper(duration, predict_time, predict_gauge, np, x, fs, X, T, eta_obs)

% Designate last column as 'test', rest as 'training'
X_train = X(:, 1:6);
T_train = T(:, 1:6);
eta_train = eta_obs(:, 1:6);

% X_test = X(:, 7);
% T_test = T(:, 7);
% eta_test = eta_obs(:, 7);

pt = predict_time * fs; % index of prediction time
nt = duration * fs; % # of indices used in reconstruction

% cutoff value for determining frequency range
c = 0.05;

% find 30 frequencies and wavenumbers
n = 30;

% Use t_past seconds of time history to calculate spectrum
t_past = 30;
[w, k, stat] = freq_range(eta_train(pt-t_past*fs:pt, :), fs, c, n);

% % use duration of past data to construct spectrum
% [w, k, stat] = freq_range(eta_train(pt-nt:pt, :), fs, c, n);

% Find linear weights of decomposition
[a, b] = linear_weights(eta_train, X_train, T_train, pt, nt, w, k);

% Generate time series in seconds for reconstruction, then evaluate the
% calculated weights at these times and the specified location
t_reconstruct = linspace(predict_time, predict_time + np*stat.pperiod, 1000)';
slice = reconstruct_one_gauge(x, t_reconstruct, k, w, a, b, predict_gauge);

% Find prediction zone
locs = x;
locs(predict_gauge) = [];

x_b = min(locs);
x_j = max(locs);
x_p = x(predict_gauge);

% c_g2 = 9.81 / (2*stat.w_hi);
% c_g1 = 9.81 / (2*stat.w_lo);

c_g1 = w(1) / (2*k(1));
c_g2 = w(end) / (2*k(end));

stat.c_g1 = c_g1;
stat.c_g2 = c_g2;

stat.zone_lo = (x_p - x_j - c_g2 * duration) / c_g2;
stat.zone_hi = (x_p - x_b) / c_g1;






