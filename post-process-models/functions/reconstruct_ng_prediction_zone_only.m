function [t_rec, r, stat] = reconstruct_ng_prediction_zone_only(pram, stat, x, t)
%
%

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

% create time series around prediction gauge prediction window
t_rec = t(pi1:pi2)';

s_a = a .* cos(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);
s_b = b .* sin(k' * ones(1, length(t_rec)) .* dx - w' * t_rec);

r = k.^(-3/2) * (s_a + s_b);

r = r';




% Add to stat
stat.c_g1 = c_g1;   % fastest group velocity
stat.c_g2 = c_g2;   % slowest group velocity
% stat.t_min = t_min; % minimum valid time after starting reconstruction
% stat.t_max = t_max; % maximum valid time after starting reconstruction

% tp1 = length(t0) + round(t_min * fs);
% tp2 = length(t0) + round(t_max * fs);
% 
% stat.tp1 = tp1;     % minimum valid time index in reconstruction time
% stat.tp2 = tp2;     % maximum valid time index in reconstruction time


