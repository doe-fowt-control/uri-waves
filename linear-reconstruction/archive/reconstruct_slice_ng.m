function [slice, t, stat] = reconstruct_slice_ng(pram, stat, X_, T_)

window = pram.window;
Ta = pram.Ta;
fs = pram.fs;
pg = pram.pg;
mg = pram.mg;
x = pram.x;

a = stat.a;
b = stat.b;
w = stat.w;
k = stat.k;

c_g1 = stat.c_g1;
c_g2 = stat.c_g2;

dx = min(x(pg) - x(mg));

t_min = dx/c_g2;
t_max = dx/c_g1 + Ta;

x_test = X_(1, pg);

% t = T_(tr*fs:(tr+np)*fs, 1);

t_target = 0:1/fs:Ta;
t0 = [];
t1 = [];
if window ~= 0
    t0 = -window:1/fs:- 1/fs;
    t1 = t_target(end) + 1/fs : 1/fs: window + t_target(end);
end

t = [t0, t_target, t1];

s_a = a .* cos(k' * ones(1, length(t)) .* x_test - w' * t);
s_b = b .* sin(k' * ones(1, length(t)) .* x_test - w' * t);

slice = k.^(-3/2) * (s_a + s_b);

stat.t_min = t_min;
stat.t_max = t_max;


