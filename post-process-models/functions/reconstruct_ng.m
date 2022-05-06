function [t_rec, r, stat] = reconstruct_ng(pram, stat, x, t)
% return reconstructed time series at location of specified prediction
% gauge `pram.pg`. Time series is dependent on calculated prediction zone

w = stat.w;
k = stat.k;
a = stat.a;
b = stat.b;

% spatial location of interest
pg = pram.pg;
mg = pram.mg;

dx = x(pg);

% calculate prediction zone time boundary
tr = pram.tr;
Ta = pram.Ta;

c_g1 = stat.c_g1;
c_g2 = stat.c_g2;

t_min = tr - Ta + 1/c_g2 * (dx - max(x(mg)));
t_max = tr + 1/c_g1 * (dx - min(x(mg)));

stat.t_min = t_min;
stat.t_max = t_max;

% prediction zone indices for full time series
[~, pi1] = min(abs(t_min - t));
[~, pi2] = min(abs(t_max - t));

stat.pi1 = pi1;
stat.pi2 = pi2;

% visualization time indices
vi1 = pi1 - round(pram.window * pram.fs);
vi2 = pi2 + round(pram.window * pram.fs);

stat.vi1 = vi1;
stat.vi2 = vi2;

t_rec = t(vi1:vi2)';

s_a = a .* cos(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);
s_b = b .* sin(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);

r = k.^(-3/2) * (s_a + s_b);

