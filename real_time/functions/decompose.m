function [stat] = decompose(pram, stat, eta_)
% Break single wave gauge data into constituent wave amplitudes, phases,
% frequencies, wavenumbers

fs = pram.fs;
mg = pram.mg;
Ta = pram.Ta;
validation_size = pram.validation_size;

% i1 = stat.i1;
% i2 = stat.i2;

eta = eta_(end - validation_size - (Ta*fs) + 1: end - validation_size, mg);

% Find amplitude, frequency, phase
y = fft(eta);           % Compute DFT of x
n = length(y);          % length of signal (output), not sure why minus 1
A = 2*abs(y/n);         % Magnitude scaled by length
A(abs(y)<1e-6) = 0;
A(1) = A(1)/2;
phi = (angle(y));       % Phase
f = (0:n-1)*fs/n;       % Frequency vector

A = A(1:round(n/2));           % Use first half of outputs
phi = phi(1:round(n/2));
f = f(1:round(n/2));
w = f * 2*pi;
k = w.^2 / 9.81;

% plot(f,A)
% xlim([0 4])

stat.k = k;
stat.w = w;
stat.A = A;
stat.phi = phi;