function [stat] = decompose_1g(pram, stat, eta_)

fs = pram.fs;
mg = pram.mg;

i1 = stat.i1;
i2 = stat.i2;

eta = eta_(i1:i2, mg);

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