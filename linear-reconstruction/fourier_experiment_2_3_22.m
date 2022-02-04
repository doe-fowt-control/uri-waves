clear
load '../data/mat/1.10.22/A.mat'

% Calculate prediction zone using one probe and fourier transform

i1 = 3;
i2 = 1;

p1 = data(:,i1);
p2 = data(:,i2);

fs = round(1/((time(end)-time(1))/numel(time)),0);

t1 = 60;            % initial time (s)
t = 10;             % assimilation time (s)
L = t*fs;           % length of signal

f = fs*(0:(L/2))/L; % frequencies (Hz)

% get sample time series
t_sample = time(t1*fs:(t1+t)*fs);
p1_sample = p1(t1*fs: (t1+t)*fs);

Y = fft(p1_sample); % calculate fft
a = abs(Y/L);       % magnitude of output divided by length of signal
A = a(1:L/2+1);     % select first half of resulting signal, 
A(2:end-1) = 2*A(2:end-1);  % double all but the first magnitude (DC)

phi = angle(Y);                     % find phase
phi = phi(1:L/2+1);

% threshold filtering on b, f, phi
mu = 0.05;
mask = A > 0.05 * max(A);
A = A(mask);
f = f(mask);
phi = phi(mask);

t_mat = f.*t_sample .* ones(length(t_sample), length(f));   % matrix for cosine evaluation

n = A'.*cos(-2*pi*t_mat - phi');     % evaluate cosine
m = sum(n,2);                       % find sum of cosine waves

% turn this into propagation (consider the wavenumber)
omega = f*2*pi;
k = omega.^2 / 9.81;

dx = x(i2) - x(i1);

t_min = dx/(0.5 * 9.81/max(omega));
t_max = dx/(0.5 * 9.81/min(omega)) + t;

if t_min > t_max
    fprintf("prediction boundary warning, t_min > t_max")
end

windowLow = 10;
windowHigh = 10;

% time indices for evaluation window
tilo = (t1+round((t_min-windowLow),0))*fs;
tihi = (t1+round((t_max+windowHigh),0))*fs;

t_meas = time(tilo:tihi);
p2_meas = p2(tilo:tihi);


t_reconstruct = time(tilo) : 1/fs : time(tihi);

t_re_mat = omega.* t_reconstruct' .* ones(length(t_reconstruct), length(f));
x_re_mat = dx*k.*ones(length(t_reconstruct), length(f));

q = A'.*cos(x_re_mat - t_re_mat - phi');
r = sum(q,2);

figure
subplot(2,1,1)
hold on
plot(t_reconstruct - t1, r, 'k--', 'linewidth', 2)
plot(t_meas - t1, p2_meas, 'b')
xline(t_min)
xline(t_max)
xlim([t_min - windowLow t_max + windowHigh])
legend('reconstruction', 'measurement')
xlabel('time (s)')
ylabel('amplitude (m)')
title('Wave forecast and measurement')

subplot(2,1,2)
plot(t_meas - t1, (r-p2_meas).^2, 'r')
xline(t_min)
xline(t_max)
xlim([t_min - windowLow t_max + windowHigh])
legend('error', 'prediction zone boundary')
xlabel('time (s)')
ylabel('square difference')
title('Error assessment for simple wave forecast')


% hold on
% plot(t_sample, m, 'k--', 'linewidth', 2);
% plot(t_sample, p1_sample)


