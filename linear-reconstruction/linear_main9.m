%% Shawn Albertson 4/6/22

% Reconstruction using `1` probe
% Plot reconstruction at prediction gauge

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/12.10.21/E.mat'

[pram, stat] = make_structs;

pram.x = x;
pram.mg = 2;

% % calibration
% load '../data/mat/3.21.22/cal.mat'
% pram.slope = cal(1, :);
% pram.intercept = cal(2,:);


% Preprocess to get spatiotemporal points and resampled observations
[t, eta] = preprocess_1g(pram, data, time, x);

% Select subset of data for remaining processing
stat = subset_1g(pram, stat, t);

stat = spectral_1g(pram, stat, eta);

% Find frequency, wavenumber, amplitude, phase
stat = decompose_1g(pram, stat, eta);

pram.pg = 1;
[t_rec, r, stat] = reconstruct_1g(pram, stat, x, t);

figure
hold on
plot(t_rec, r)
plot(t_rec, eta(stat.vi1: stat.vi2, pram.pg))
xline(0, 'k--')  % reconstruction time
xline(stat.t_min)
xline(stat.t_max)

legend('prediction', 'measurement', 'reconstruction time', 'prediction zone')
xlabel('time (s)')
ylabel('amplitude (m)')
title('Wave forecast and measurement')





