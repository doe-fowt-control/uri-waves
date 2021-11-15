%% Define simple wave to test algorithm
clear
% generate constants
g = 9.81;       % gravity [m/s]
L = 2;          % wavelength [m]
k = 2*pi / L;   % wavenumber [1/m]
w = sqrt(g*k);  % frequency [1/s] (deep water dispersion)
P = 2*pi / w;   % period [s]

% generate time and space series
cycles = 2;
x = linspace(0, L*cycles, 1);
% x = 0;
t = linspace(0, P*cycles, 20000);

% create mesh for evaluation
[X, T] = meshgrid(x, t);
wave = sin(2*pi*X/L - w*T);

% awgn function adds Gaussian white noise, parameter 'signal to noise ratio'
wave = awgn(wave, 20);



% wave_noise = awgn(wave, 20);
% plot(wave_noise(1, :));

x_stack = reshape(X, [1, numel(X)]);
t_stack = reshape(T, [1, numel(T)]);

% wavenumbers for reconstruction
n = 10;
k_lo = pi/2;
k_hi = 3*pi/2;
k_n = logspace(log(k_lo), log(k_hi), n);

w_n = sqrt(g.*k_n);

psi = k_n' * x_stack - w_n' * t_stack;

bloc11 = cos(psi)*cos(psi)';
bloc12 = cos(psi)*sin(psi)';
bloc21 = sin(psi)*cos(psi)';
bloc22 = sin(psi)*sin(psi)';

% Apply preconditioning before inversion
 
alpha  = diag(k_n'.^(-3/2));

A = [bloc11*alpha, bloc12*alpha; bloc21*alpha,bloc22*alpha];

eta_obs = reshape(wave, [numel(wave), 1]);

B1 = cos(psi)*eta_obs;
B2 = sin(psi)*eta_obs;

B  = [B1;B2];

weights = A\B;

a_n = weights(1:n);
b_n = weights(n+1:end);

x_test = linspace(0, L*cycles, 100);
i = 1;
t_test = t(i);

s_a = a_n .* cos(k_n'*x_test - w_n'* ones(1,length(x_test)) .* t_test);
s_b = b_n .* sin(k_n'*x_test - w_n'* ones(1,length(x_test)) .* t_test);

s = k_n.^(-3/2) * (s_a + s_b);
c = sum(s, 1);
clf;
hold on
plot(x_test, c, 'r')
plot(x, wave(i, :), 'bo')
legend('Reconstruction', 'Measurements')
title('Reconstruction at time = 0; x_n = 2, t_n = 200')
ylabel('Amplitude []')
xlabel('x-location []')









