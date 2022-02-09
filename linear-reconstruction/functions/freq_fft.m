function [w, k, A, phi] = freq_fft(param, eta)

Ta = param.Ta;
fs = param.fs;

p1_sample = eta;

L = Ta*fs;          % length of signal
f = fs*(0:(L/2))/L; % frequencies (Hz)

Y = fft(p1_sample); % calculate fft
a = abs(Y/L);       % magnitude of output divided by length of signal
A = a(1:L/2+1);     % select first half of resulting signal, 
A(2:end-1) = 2*A(2:end-1);  % double all but the first magnitude (DC)

phi = angle(Y);             % find phase
phi = phi(1:L/2+1);


% Threshold filtering on A, f, phi
% TODO make this more robust
c = 0.05;
E = trapz(f, A); % total energy
S = cumtrapz(f, A); % energy integral

R = S / E; % percent of total energy at each bin

[lo_val, lo_idx] = min(abs(R - c));
[hi_val, hi_idx] = min(abs(R - (1-c)));
A = A(lo_idx: hi_idx);
f = f(lo_idx: hi_idx);
phi = phi(lo_idx: hi_idx);

% Consider the wavenumber
w = f * 2*pi;
k = w.^2 / 9.81;