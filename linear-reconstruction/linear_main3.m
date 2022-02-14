%% Shawn Albertson
% Published: 2/11/21
% Updated:   2/11/21

% Perform reconstruction using a single probe using FFT
% Evaluate the error between the wave reconstruction and measurement

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'
% load '../data/mat/12.10.21/D.mat'

param = struct;
param.fs = 32;          % sampling frequency
param.tr = 50.1;          % reconstruction time
param.Ta = 5;          % reconstruction assimilation time
param.mu = .05;         % cutoff threshold
param.mg = 2;           % measurement gauges
param.pg = 1;           % gauge to predict at
param.pt = param.tr * param.fs + 1; % index of prediction time
param.nt = param.Ta * param.fs; % # indices used in reconstruction
param.window = 5;              % number of seconds outside of prediction to use

mg = param.mg;
pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;
pt = param.pt;
nt = param.nt;
window = param.window;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(param, data, time, x);

% Try removing entries from full time array
T_(1:100, :) = [];

% Select subset of data for remaining processing
[param, X, T, eta] = subset(param, X_, T_, eta_);

% figure
% hold on
% plot(T, eta, 'r-', 'linewidth', 1)
% plot(time, data(:, mg), 'k--', 'linewidth', 2)
% xlim([tr-Ta tr])
% legend('processed', 'raw')
% title('sanity check on fft inputs')

% Find frequency, wavenumber, amplitude, phase
[w, k, A, phi, i] = freq_fft(param, eta);

% Evaluate reconstruction at reconstruction time 
% t_sample = T_(pt-nt-window*fs:pt+window*fs, 1);
t_sample = T_(param.i1 - window*fs:param.i2 + window * fs, 1) - T_(param.i1 - window*fs, 1);

t_now_mat = t_sample .* ones(length(t_sample), length(w));   % matrix for cosine evaluation
t_mat = w.*t_now_mat;

n = A'.*cos(-t_mat - phi');     % evaluate cosine
m = sum(n,2);                   % find sum of cosine waves

% z = sum(t_sample-T);

figure
% subplot(2,1,1)
hold on
plot(t_sample, m, 'k--', 'linewidth', 2);
plot(t_sample, eta_(param.i1 - window*fs:param.i2 + window * fs, mg), 'linewidth', 1)
plot(T_(param.i1:param.i2,1) - T_(param.i1,1) + window, i, 'b.');
% plot(t_sample, eta_(pt-nt-window*fs:pt+window*fs, mg), 'linewidth', 1)
% xline(tr-Ta)
% xline(tr)
legend('reconstruction', 'measurement', 'ifft')

% subplot(2,1,2)
% hold
% plot(t_sample, (m - eta_(param.i1: param.i2, mg)).^2)
% % plot(t_sample, (m - eta_(pt-nt-window*fs:pt+window*fs, mg)).^2)
% xline(tr-Ta)
% xline(tr)





