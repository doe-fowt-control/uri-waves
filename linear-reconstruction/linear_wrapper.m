function [slice, t_reconstruct, stat] = linear_wrapper(param, predict_gauge, np, x, X, T, eta_obs)

Ta = param.Ta;
tr = param.tr;
fs = param.fs;

% Designate last column as 'test', rest as 'training'
X_train = X(:, 1:6);
T_train = T(:, 1:6);
eta_train = eta_obs(:, 1:6);

pt = tr * fs; % index of prediction time
nt = Ta * fs; % # of indices used in reconstruction

% Calculate spectrum using specified spectral assimilation time
ts = param.ts;
[w, k, stat] = freq_range(eta_train(pt-ts*fs:pt, :), param);

% Find linear weights of decomposition
[a, b] = linear_weights(eta_train, X_train, T_train, pt, nt, w, k);

% Generate time series in seconds for reconstruction, then evaluate the
% calculated weights at these times and the specified location
t_reconstruct = linspace(tr, tr + np*stat.pperiod, 1000)';
slice = reconstruct_one_gauge(x, t_reconstruct, k, w, a, b, predict_gauge);

% Find prediction zone
locs = x;
locs(predict_gauge) = [];

x_b = min(locs);
x_j = max(locs);
x_p = x(predict_gauge);

c_g1 = 9.81 / (2 * stat.w_lo_pred);
c_g2 = 9.81 / (2 * stat.w_hi_pred);

stat.c_g1 = c_g1;
stat.c_g2 = c_g2;

stat.zone_lo = (x_p - x_j - c_g2 * Ta) / c_g2;
stat.zone_hi = (x_p - x_b) / c_g1;






