function [t, slice, stat] = reconstruct_for_prediction_region(pram, stat, x, t)
% return reconstructed time series at location of specified prediction
% gauge `pram.pg`. Time series used for linear_main7 to visualize full
% prediction region, especially how it narrows moving away from measurement

w = stat.w;
k = stat.k;
A = stat.A;
phi = stat.phi;

% spatial location of interest
pg = pram.pg;
mg = pram.mg;

dx = x(pg) - x(mg);

% calculate prediction zone time boundary, rounded to sampling frequency
Ta = pram.Ta;
fs = pram.fs;

c_g1 = stat.c_g1;
c_g2 = stat.c_g2;

t_min = dx/c_g2;
t_max = dx/c_g1 + Ta;

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

% make reconstruction time series, located at zero due to FFT
window = pram.window;
window = 1/fs*round(window*fs);

stat.vi1 = pi1 - round(window * fs);
stat.vi2 = pi2 + round(window * fs);

t_target = 0:1/fs:Ta;
t0 = [];
t1 = [];
if window ~= 0
    t0 = -window : 1/fs : -1/fs;
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

t_now_mat = t' .* ones(length(t), length(w));   % matrix for cosine evaluation
t_re_mat = w.*t_now_mat;

x_re_mat = k.*     dx         .* ones(length(t), length(w));

% Check to see which orientation of A and phi work
q = A'.*cos(x_re_mat - t_re_mat - phi');
% q = A.*cos(x_re_mat - t_re_mat - phi);


slice = sum(q,2);


