%% Shawn Albertson
% Original date: 2/9/21
% Last updated: 2/9/21

% Perform reconstruction using a single probe worth of data and FFT
% Evaluate the error between the wave propagation and measurement

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'

param = struct;
param.fs = 64;          % sampling frequency
param.tr = 60;          % reconstruction time
param.Ta = 15;          % reconstruction assimilation time
param.nf = 20;          % number of frequencies used for reconstruction
param.mu = .03;         % cutoff threshold
param.mg = 2;         % measurement gauges
param.pg = 1;           % gauge to predict at
param.np = 15;          % number of periods to predict for
param.pt = param.tr * param.fs; % index of prediction time
param.nt = param.Ta * param.fs; % # indices used in reconstruction

% Calculate prediction zone using one probe and fourier transform

mg = param.mg;
pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;


% Preprocess to get spatiotemporal points and resampled observations
[X_, T_, eta_] = preprocess(param, data, time, x);

% Select subset of data for remaining processing
[X, T, eta] = subset(param, X_, T_, eta_);

% Find frequency, wavenumber, amplitude, phase
[w, k, A, phi] = freq_fft(param,eta);

% % Evaluating reconstruction at time calculated
% t_mat = w.*t_sample .* ones(length(t_sample), length(w));   % matrix for cosine evaluation
% 
% n = A'.*cos(-t_mat - phi');     % evaluate cosine
% m = sum(n,2);                       % find sum of cosine waves
% 
% figure
% hold on
% plot(T, m, 'k--', 'linewidth', 2);
% plot(T, eta)

dx = x(pg) - x(mg);

c_g1 = 9.81/(min(w)*2);
c_g2 = 9.81/(max(w)*2);

t_min = dx/c_g2;
t_max = dx/c_g1 + Ta;

if t_min > t_max
    fprintf("prediction boundary warning, t_min > t_max")
end

windowLow = 10;
windowHigh = 10;

% time indices for evaluation window
tilo = (tr-Ta+round((t_min-windowLow),0))*fs;
tihi = (tr-Ta+round((t_max+windowHigh),0))*fs;

t_meas = time(tilo:tihi);

p2 = eta_(:,pg);
p2_meas = p2(tilo:tihi);


t_reconstruct = time(tilo) : 1/fs : time(tihi);

t_re_mat = w.* t_reconstruct' .* ones(length(t_reconstruct), length(w));
x_re_mat = k.*     dx         .* ones(length(t_reconstruct), length(w));

q = A'.*cos(x_re_mat - t_re_mat - phi');
r = sum(q,2);

figure
subplot(2,1,1)
hold on
plot(t_reconstruct, r, 'k--', 'linewidth', 2)
plot(t_meas, p2_meas, 'b')
xline(t_min+tr-Ta)
xline(t_max+tr-Ta)
% xline(tr, 'k--')
% xlim([t_min - windowLow t_max + windowHigh])
legend('reconstruction', 'measurement', 'prediction zone boundary')
xlabel('time (s)')
ylabel('amplitude (m)')
title('Wave forecast and measurement')

subplot(2,1,2)
plot(t_meas, (r-p2_meas).^2, 'r')
xline(t_min+tr-Ta)
xline(t_max+tr-Ta)
% xline(tr-Ta, 'k--')
% xlim([t_min - windowLow t_max + windowHigh])
legend('error', 'prediction zone boundary')
xlabel('time (s)')
ylabel('square difference')
title('Error assessment for simple wave forecast')





