%% Load data
clear

load '../data/11.8.21_run2.mat'
load '../data/11.8.21.time.mat'

t_lo = 3000;
t_hi = 12000;
t = time(t_lo:t_hi, 1);

% Specify locations
x = [2.934, 2.604, 2.172, 1.632, 0.953, 0];

% Get wave height data
eta_obs = data(t_lo:t_hi, :);

% Center on mean
eta_obs = eta_obs - mean(eta_obs);

[X, T] = meshgrid(x, t);

% % Specify wavenumbers for reconstruction using one of a few methods, actual -> 2.2081
k_n = 2.2081;
k_n = [2.1581, 2.2081, 2.2581];
k_n = linspace(2.1981, 2.2181, 20);

% Specify corresponding frequencies using deepwater dispersion relation
n = length(k_n);
g = 9.81;
w_n = sqrt(g.*k_n);

% % This is a vector which could be used to visualize reconstruction in space
% x_test = linspace(min(x), max(x));

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



%%

fs = 1/((t(end)-t(1))/numel(t));
% [pxx, f] = pwelch(eta_obs(:, 1), 5000, 500, 5000, fs);

[pxx, f] = pwelch(eta_obs(:, 1), length(eta_obs), [],[], fs);
% [pxx, f] = pwelch(eta_obs, length(eta_obs), [], [], fs);
plot(f, pxx);
xlim([0 1]);

% cut off frequencies with less than one percent of the energy
c = 0.01;
thresh = pxx > max(pxx)*c;

frel = f(thresh);
lo = min(frel);
hi = max(frel);

w = linspace(lo, hi, n);

smallest_change = (hi-lo)./(3*n);
size_norm = pxx(thresh)/max(pxx(thresh)); % large value for frequencies of importance
increment = smallest_change.*(1./size_norm); 

j = 1;
fdist = [lo];
for i = 1:length(frel)-1
    while fdist(j) < frel(i+1)
        fdist(j+1) = fdist(j) + increment(i);
        j = j+1;
    end
end

% (2*pi.*w).^2./g

