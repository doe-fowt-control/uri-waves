function [t, slice, stat] = reconstruct_ng_for_prediction_region(pram, stat, x, t)
% used for `niter` cases to visualize the same window for multiple
% realizations

w = stat.w;
k = stat.k;
a = stat.a;
b = stat.b;

% spatial location of interest
pg = pram.pg;
mg = pram.mg;

dx = x(pg);

% calculate prediction zone time boundary, rounded to sampling frequency
tr = pram.tr;
Ta = pram.Ta;
fs = pram.fs;

c_g1 = stat.c_g1;
c_g2 = stat.c_g2;

t_min = tr - Ta + 1/c_g2 * (dx - max(x(mg)));
t_max = tr + 1/c_g1 * (dx - min(x(mg)));

t_min = 1/fs*round(t_min*fs);
t_max = 1/fs*round(t_max*fs);

stat.t_min = t_min;
stat.t_max = t_max;

if t_min > t_max
    fprintf("prediction boundary warning, t_min > t_max")
end

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

% make reconstruction time series
window = pram.window;
window = 1/fs*round(window*fs);

t_target = t(stat.i1 : stat.i2+1)';
t0 = [];
t1 = [];
if window ~= 0
    t0 = t(pi1) - window : 1/fs : t(pi1) - 1/fs;
    t1 = max(t_target) + 1/fs : 1/fs : window + max(t_target);
end

% % time series if single visual is most important
% t_target = t_min:1/fs:t_max;
% t0 = [];
% t1 = [];
% if window ~= 0
%     t0 = t_min-window : 1/fs : t_min-1/fs;
%     t1 = t_max + 1/fs : 1/fs : window + t_max;
% end

t = [t0, t_target, t1];

s_a = a .* cos(k' * ones(1, length(t)) .* dx - w' * t);
s_b = b .* sin(k' * ones(1, length(t)) .* dx - w' * t);

r = k.^(-3/2) * (s_a + s_b);

slice = r';










