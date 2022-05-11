function [t_rec, r, stat] = reconstruct_fixed_1g(pram, stat, x, t)
% Reconstruct at fixed time window to make figure that shows prediction
% region for all measured locations

w = stat.w;
k = stat.k;
a = stat.a;
b = stat.b;

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

stat.t_min = t_min; % minimum valid time after starting reconstruction
stat.t_max = t_max; % maximum valid time after starting reconstruction

if t_min > t_max
    fprintf("prediction boundary warning, t_min > t_max")
end

% prediction zone indices for full time series
[~, pi1] = min(abs(tr - Ta + t_min - t));
[~, pi2] = min(abs(tr - Ta + t_max - t));

stat.pi1 = pi1;
stat.pi2 = pi2;

% visualization indices
window = pram.window;
window = 1/fs*round(window*fs);

stat.vi1 = pi1 - round(window * fs);
stat.vi2 = pi2 + round(window * fs);

% create time series around assimilation time
t_target = 0:1/fs:Ta;
t0 = [];
t1 = [];
if window ~= 0
    t0 = min(t_target) - window : 1/fs : min(t_target) - 1/fs;
    t1 = max(t_target) + 1/fs : 1/fs : window + max(t_target);
end

t_rec = [t0, t_target, t1];

% prediction zone indices relative to reconstructed block
[~, rpi1] = min(abs(t_min - t_rec));
[~, rpi2] = min(abs(t_max - t_rec));

stat.rpi1 = rpi1;
stat.rpi2 = rpi2;

% reconstruct based on surface representation
s_a = a .* cos(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);
s_b = b .* sin(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);

% THIS WOULD BE K^(-3/2) * [...] FOR LEAST SQUARES INVERSION
r = ones(size(k)) * (s_a + s_b);




