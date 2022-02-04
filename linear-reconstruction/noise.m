clear
load '../data/mat/1.10.22/A.mat'

fs_old = round(1/((time(end)-time(1))/numel(time)), 0);
fs = 32;

data = data(1: fs_old / fs : end, :);
time = time(1: fs_old / fs : end);

signal_t0 = 30 * fs;
signal_t1 = 90 * fs;
time_signal = time(signal_t0:signal_t1);
data_signal = data(signal_t0:signal_t1, 1);

noise_t0 = 280 * fs;
noise_t1 = 345 * fs;
time_noise = time(noise_t0:noise_t1);
data_noise = data(noise_t0:noise_t1, 1);

figure
hold on

plot(time, data(:,1))
xline(30, 'LineWidth', 1)
xline(90, 'LineWidth', 1)
xline(280, 'LineWidth', 1)
xline(340, 'LineWidth', 1)
xlabel('time (s)')
ylabel('amplitude (m)')

[pxxs, ffs] = pwelch(data_signal, [], [], 1024, fs);
[pxxn, fn] = pwelch(data_noise, [], [], 1024, fs);

figure
hold on
loglog(ffs, pxxs, 'b')
loglog(fn, pxxn, 'r')
loglog(ffs, pxxs-pxxn, 'g')
legend('signal', 'noise')
xlim([0 4])
