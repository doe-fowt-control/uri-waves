function [w, k, A, phi] = freq_fft(param, eta)

fs = param.fs;
mu = param.mu;


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

% Threshold filtering on A, f, phi
% TODO make this more robust
E = trapz(f, A); % total energy
S = cumtrapz(f, A); % energy integral

R = S / E; % percent of total energy at each bin

[lo_val, lo_idx] = min(abs(R - mu/2));
[hi_val, hi_idx] = min(abs(R - (1-5*mu)));
A = A(lo_idx: hi_idx);
f = f(lo_idx: hi_idx);
phi = phi(lo_idx: hi_idx);

% Consider the wavenumber
w = f * 2*pi;
k = w.^2 / 9.81;