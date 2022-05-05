function [t_rec, r, stat] = reconstruct_1g(pram, stat, x, t)
% return reconstructed time series at location of specified prediction
% gauge `pram.pg`. Time series based on prediction zone at individual gauge

w = stat.w;
k = stat.k;
A = stat.A;
phi = stat.phi;

% spatial location of interest
pg = pram.pg;
mg = pram.mg;

dx = abs(x(pg) - x(mg));

% calculate prediction zone time boundary, rounded to sampling frequency
tr = pram.tr;
Ta = pram.Ta;
fs = pram.fs;

c_g1 = stat.c_g1;
c_g2 = stat.c_g2;

t_min = dx/c_g2;
t_max = dx/c_g1 + Ta;

t_min = 1/fs*round(t_min*fs);
t_max = 1/fs*round(t_max*fs);


if t_min > t_max
    fprintf("prediction boundary warning, t_min > t_max")
end

% prediction zone indices
[~, pi1] = min(abs(tr - Ta + t_min - t));
[~, pi2] = min(abs(tr - Ta + t_max - t));

stat.pi1 = pi1;
stat.pi2 = pi2;

% make reconstruction time series, located at zero due to FFT
window = pram.window;
window = 1/fs*round(window*fs);

stat.vi1 = pi1 - round(window * fs);
stat.vi2 = pi2 + round(window * fs);

% create time series around prediction gauge prediction window
t_target = t_min:1/fs:t_max;
t0 = [];
t1 = [];
if window ~= 0
    t0 = t_min-window : 1/fs : t_min-1/fs;
    t1 = t_max + 1/fs : 1/fs : window + t_max;
end

t_rec = [t0, t_target, t1];

t_now_mat = t_rec' .* ones(length(t_rec), length(w));   % matrix for cosine evaluation
t_re_mat = w.*t_now_mat;

x_re_mat = k.*     dx         .* ones(length(t_rec), length(w));

% % Check to see which orientation of A and phi work
q = A'.*cos(x_re_mat - t_re_mat - phi');
% q = A.*cos(x_re_mat - t_re_mat - phi);


r = sum(q,2);




% Add to stat
stat.c_g1 = c_g1;   % fastest group velocity
stat.c_g2 = c_g2;   % slowest group velocity
stat.t_min = t_min; % minimum valid time after starting reconstruction
stat.t_max = t_max; % maximum valid time after starting reconstruction

tp1 = length(t0) + round(t_min * fs);
tp2 = length(t0) + round(t_max * fs);

stat.tp1 = tp1;     % minimum valid time index in reconstruction time
stat.tp2 = tp2;     % maximum valid time index in reconstruction time


