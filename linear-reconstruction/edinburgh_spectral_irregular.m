%% Load data
clear

load '../data/12.1.21/data.mat'
load '../data/12.1.21/time.mat'


%%
t_lo = 5000;
t_hi = 15000;

% does it make sense to select this time window before doing anything else?
% It seems kinda wierd... especially because we end up sub-selecting the
% data using linear_weights_sampled


% Should

t = time(t_lo:t_hi, 1);

% Specify locations
x = [2.934, 2.604, 2.172, 1.632, 0.953, 0];

% Get wave height data
eta_obs = data(t_lo:t_hi, :);

% Center on mean
eta_obs = eta_obs - mean(eta_obs);

% Make spatiotemporal instances
[X, T] = meshgrid(x, t);

fs = 1/((t(end)-t(1))/numel(t));
c = 0.01;

g = 9.81;


figure
nx = 6; % number of spatial points -> choose 6 to use all wave gauges


n1 = 30;
[w_n1, k_n1, m01] = freq_range(eta_obs, fs, c, n1);

nt = 3000; % number of temporal points -> 3000 uses 30s data for reconstruction
[a_n_13, b_n_13] = linear_weights_sampled(eta_obs, X, T, nx, nt, k_n1);
% Use weights to make reconstruction
slice13 = reconstruct_slice(x, t, k_n1, w_n1, a_n_13, b_n_13, 't', 1);

nt = 5000; % number of temporal points -> 5000 uses 50s data for reconstruction
[a_n_15, b_n_15] = linear_weights_sampled(eta_obs, X, T, nx, nt, k_n1);
% Use weights to make reconstruction
slice15 = reconstruct_slice(x, t, k_n1, w_n1, a_n_15, b_n_15, 't', 1);

n2 = 50;
[w_n2, k_n2, m02] = freq_range(eta_obs, fs, c, n2);

nt = 3000; % number of temporal points -> 3000 uses 30s data for reconstruction
[a_n_23, b_n_23] = linear_weights_sampled(eta_obs, X, T, nx, nt, k_n2);
% Use weights to make reconstruction
slice23 = reconstruct_slice(x, t, k_n2, w_n2, a_n_23, b_n_23, 't', 1);

nt = 5000; % number of temporal points -> 5000 uses 50s data for reconstruction
[a_n_25, b_n_25] = linear_weights_sampled(eta_obs, X, T, nx, nt, k_n2);
% Use weights to make reconstruction
slice25 = reconstruct_slice(x, t, k_n2, w_n2, a_n_25, b_n_25, 't', 1);



hold on

% plot(x, eta_obs(1, :), 'bo', "Color", [0.05, 0.4, 0.07, 1])
% plot(x_test, slice1, "LineWidth", 1.5)

plot(t, eta_obs(:, 1), "Color", [0.05, 0.4, 0.07, 1])
plot(t, slice13, "LineWidth", 1.5, 'LineStyle', '-.')
legend("Raw data", "Reconstruction")
ylim([-.04 .04])
xlim([30 50])
title("Reconstructed wave gauge data")
xlabel("Time (s)")
ylabel("Height (m)")



