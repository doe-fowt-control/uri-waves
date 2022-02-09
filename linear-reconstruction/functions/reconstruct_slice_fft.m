function [slice, t, stat] = reconstruct_slice_fft(param, stat, X_, T_, w, k, A, phi)

window = param.window;
tr = param.tr;
Ta = param.Ta;
fs = param.fs;
pg = param.pg;
mg = param.mg;

dx = X_(1, pg) - X_(1, mg);

c_g1 = 9.81 / (min(w)*2);
c_g2 = 9.81 / (max(w)*2);

t_min = dx/c_g2;
t_max = dx/c_g1 + Ta;

if t_min > t_max
    fprintf("prediction boundary warning, t_min > t_max")
end

% time indices for evaluation window
tr1 = (tr-Ta+round((t_min-window),0))*fs;
tr2 = (tr-Ta+round((t_max+window),0))*fs;
t = T_(tr1:tr2, 1);

tp1 = round((tr-Ta+t_min)*fs) - tr1;
tp2 = round((tr-Ta+t_max)*fs) - tr1;

t_re_mat = w.* t .* ones(length(t), length(w));
x_re_mat = k.*     dx         .* ones(length(t), length(w));

q = A'.*cos(x_re_mat - t_re_mat - phi');
slice = sum(q,2);


% Add to stat
stat.c_g1 = c_g1;   % fastest group velocity
stat.c_g2 = c_g2;   % slowest group velocity
stat.t_min = t_min; % minimum valid time after starting reconstruction
stat.t_max = t_max; % maximum valid time after starting reconstruction
stat.tr1 = tr1;     % minimum time index for reconstruction
stat.tr2 = tr2;     % maximum time index for reconstruction
stat.tp1 = tp1;     % minimum valid time index in reconstruction time
stat.tp2 = tp2;     % maximum valid time index in reconstruction time


