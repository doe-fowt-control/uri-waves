function check_reconstruction(pram, stat, eta)

i1 = stat.i1; % indices for reconstruction in full time series
i2 = stat.i2;
window = pram.window;
fs = pram.fs;
mg = pram.mg;
Ta = pram.Ta;

w = stat.w;
A = stat.A;
phi = stat.phi;


% t_sample = T_(i1 - window*fs: i2 + window*fs, 1) - T_(i1 - window*fs, 1);
t = 0:1/fs:Ta;
t0 = [];
t1 = [];
if window ~= 0
    t0 = -window:1/fs:-1/fs;
    t1 = t(end) + 1/fs : 1/fs: window + t(end);
end

t_sample = [t0, t, t1];


t_now_mat = t_sample' .* ones(length(t_sample), length(w));   % matrix for cosine evaluation
t_re_mat = w.*t_now_mat;

n = A'.*cos(-t_re_mat - phi');     % evaluate cosine
m = sum(n,2);                   % find sum of cosine waves

figure
subplot(2,1,1)
hold on
plot(t_sample, m, 'k--', 'linewidth', 2);
plot(t_sample, eta(i1 - window*fs:i2 + window * fs + 1, mg(1)), 'b-', 'linewidth', 1)
xline(0, 'g-.', 'LineWidth', 1)
xline(Ta, 'r-.', 'LineWidth', 1)
legend('reconstruction', 'measurement', 'assimilation start', 'assimilation end')
title('Reconstruction')
xlabel('time (s)')
ylabel('Amplitude (m)')

subplot(2,1,2)
hold
plot(t_sample, abs(m - eta(i1 - window*fs:i2 + window * fs + 1, mg(1))), 'k-')
xline(0, 'g-.', 'LineWidth', 1)
xline(Ta, 'r-.', 'LineWidth', 1)
legend('error', 'assimilation start', 'assimilation end')
xlabel('time (s)')
ylabel('Absolute difference (m)')
title('Reconstruction error')