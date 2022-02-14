%% Shawn Albertson
% Published: 2/9/21
% Updated:   2/9/21

% Perform reconstruction using a single probe using FFT
% Evaluate the error between the wave propagation and measurement

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'
% load '../data/mat/12.10.21/D.mat'

param = struct;
param.fs = 32;          % sampling frequency
param.tr = 75;          % reconstruction time
param.Ta = 15;          % reconstruction assimilation time
param.nf = 20;          % number of frequencies used for reconstruction
param.mu = .05;         % cutoff threshold
param.mg = 2;           % measurement gauges
param.pg = 1;           % gauge to predict at
param.pt = param.tr * param.fs; % index of prediction time
param.nt = param.Ta * param.fs; % # indices used in reconstruction
param.window = 10;              % number of seconds outside of prediction to use

mg = param.mg;
pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(param, data, time, x);

% Select subset of data for remaining processing
[X, T, eta] = subset(param, X_, T_, eta_);

% Find frequency, wavenumber, amplitude, phase
[w, k, A, phi] = freq_fft(param,eta);

% % Evaluating reconstruction at reconstruction time 
% t_mat = w.*t_sample .* ones(length(t_sample), length(w));   % matrix for cosine evaluation
% 
% n = A'.*cos(-t_mat - phi');     % evaluate cosine
% m = sum(n,2);                       % find sum of cosine waves
% 
% figure
% hold on
% plot(T, m, 'k--', 'linewidth', 2);
% plot(T, eta)

% Reconstruct at perscribed time window
[r, t, stat] = reconstruct_slice_fft(param, stat, X_, T_, w, k, A, phi);

% Unpack indices for reconstruction
tr1 = stat.tr1;
tr2 = stat.tr2;

% Unpack time values for prediction window
t_min = stat.t_min;
t_max = stat.t_max;

% Get corresponding measured data
p = eta_(tr1:tr2, pg);

% Normalized root mean square error
e = rmse(r, p, stat);

figure
subplot(2,1,1)
hold on
plot(t, r, 'k--', 'linewidth', 2)
plot(t, p, 'b')
xline(t_min+tr-Ta)
xline(t_max+tr-Ta)
% xline(tr, 'k--')
% xlim([t_min - windowLow t_max + windowHigh])
legend('reconstruction', 'measurement', 'prediction zone boundary')
xlabel('time (s)')
ylabel('amplitude (m)')
title('Wave forecast and measurement')

subplot(2,1,2)
plot(t, (r-p).^2, 'r')
xline(t_min+tr-Ta)
xline(t_max+tr-Ta)
% xline(tr-Ta, 'k--')
% xlim([t_min - windowLow t_max + windowHigh])
legend('error', 'prediction zone boundary')
xlabel('time (s)')
ylabel('square difference')
title('Error assessment for simple wave forecast')





