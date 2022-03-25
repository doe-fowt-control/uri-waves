function [slice, t, stat] = reconstruct_slice_fft(pram, stat, x)
% Reconstruct for prediction window

% window = pram.window;
% Ta = pram.Ta;
% fs = pram.fs;
pg = pram.pg;
mg = pram.mg;

w = stat.w;
k = stat.k;
A = stat.A;
phi = stat.phi;

% dx = X_(1, pg) - X_(1, mg);
dx = x(pg) - x(mg);

% c_g1 = stat.c_g1;
% c_g2 = stat.c_g2;
% 
% t_min = dx/c_g2;
% t_max = dx/c_g1 + Ta;
% 
% if t_min > t_max
%     fprintf("prediction boundary warning, t_min > t_max")
% end
% 
% 
% t_target = 0:1/fs:Ta;
% t0 = [];
% t1 = [];
% if window ~= 0
%     t0 = -window:1/fs:- 1/fs;
%     t1 = t_target(end) + 1/fs : 1/fs: window + t_target(end);
% end
% 
% t = [t0, t_target, t1];

t = linspace(0, pram.forecast_length);

t_now_mat = t' .* ones(length(t), length(w));   % matrix for cosine evaluation
t_re_mat = w.*t_now_mat;

x_re_mat = k.*     dx         .* ones(length(t), length(w));

q = A'.*cos(x_re_mat - t_re_mat - phi');

slice = sum(q,2);




% Add to stat
% stat.c_g1 = c_g1;   % fastest group velocity
% stat.c_g2 = c_g2;   % slowest group velocity
% stat.t_min = t_min; % minimum valid time after starting reconstruction
% stat.t_max = t_max; % maximum valid time after starting reconstruction

% tp1 = length(t0) + round(t_min * fs);
% tp2 = length(t0) + round(t_max * fs);

% stat.tp1 = tp1;     % minimum valid time index in reconstruction time
% stat.tp2 = tp2;     % maximum valid time index in reconstruction time
