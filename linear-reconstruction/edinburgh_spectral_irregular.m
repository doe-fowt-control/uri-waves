%% Load data
clear

load '../data/12.1.21/data.mat'
load '../data/12.1.21/time.mat'


%%
t_lo = 5000;
t_hi = 15000;

t = time(t_lo:t_hi, 1);

% Specify locations
x = [2.934, 2.604, 2.172, 1.632, 0.953, 0];

% Get wave height data
eta_obs = data(t_lo:t_hi, :);

% Center on mean
eta_obs = eta_obs - mean(eta_obs);

[X, T] = meshgrid(x, t);

fs = 1/((t(end)-t(1))/numel(t));
c = 0.01;
n = 30;
g = 9.81;

w_n = freq_range(eta_obs, fs, c, n, 0);

k_n = w_n.^2./g;

figure
nx = 6; % number of spatial points -> choose 6 to use all wave gauges
nt = 3000; % number of temporal points -> 3000 uses 30s data for reconstruction
[a_n_1, b_n_1] = linear_weights_sampled(eta_obs, X, T, nx, nt, k_n);

% Use weights to make reconstruction
slice1 = reconstruct_slice(x, t, k_n, w_n, a_n_1, b_n_1, 't', 1);

hold on

% plot(x, eta_obs(1, :), 'bo', "Color", [0.05, 0.4, 0.07, 1])
% plot(x_test, slice1, "LineWidth", 1.5)

plot(t, eta_obs(:, 1), "Color", [0.05, 0.4, 0.07, 1])
plot(t, slice1, "LineWidth", 1.5, 'LineStyle', '-.')
legend("Raw data", "Reconstruction")
ylim([-.04 .04])
xlim([30 50])
title("Reconstructed wave gauge data")
xlabel("Time (s)")
ylabel("Height (m)")



