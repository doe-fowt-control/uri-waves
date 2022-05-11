function [t_rec, r, stat] = reconstruct_window_ng(pram, stat, x, t, setting)
% return reconstructed time series at location of specified prediction
% gauge `pram.pg`. Time series is dependent on calculated prediction zone
%
%

pg = pram.pg;
mg = pram.mg;
tr = pram.tr;
Ta = pram.Ta;
fs = pram.fs;

w = stat.w;
k = stat.k;
a = stat.a;
b = stat.b;
c_g1 = stat.c_g1;
c_g2 = stat.c_g2;

% spatial location of interest
dx = x(pg);

% prediction zone time boundary relative to the beginning of assimilation
t_min = (dx - max(x(mg))) / c_g2;
t_max = (dx - min(x(mg))) / c_g1 + Ta;

t_min = 1/fs*round(t_min*fs);
t_max = 1/fs*round(t_max*fs);

stat.t_min = t_min;
stat.t_max = t_max;

if t_min > t_max
    fprintf("WARNING || t_min > t_max || ")
end

% prediction zone indices for full time series
[~, pi1] = min(abs(tr - Ta + t_min - t));
[~, pi2] = min(abs(tr - Ta + t_max - t));

stat.pi1 = pi1;
stat.pi2 = pi2;

% visualization time indices
window = pram.window;
window = 1/fs*round(window*fs);

stat.vi1 = pi1 - round(window * pram.fs);
stat.vi2 = pi2 + round(window * pram.fs);

% create time series around prediction window
t_rec = t(stat.vi1:stat.vi2)';

% prediction zone indices relative to reconstructed block
[~, rpi1] = min(abs(t_min - t_rec));
[~, rpi2] = min(abs(t_max - t_rec));

stat.rpi1 = rpi1;
stat.rpi2 = rpi2;

% reconstruct based on surface representation
s_a = a .* cos(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);
s_b = b .* sin(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);

r = k.^(-3/2) * (s_a + s_b);





