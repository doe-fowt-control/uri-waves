function [w, k, A, phi, i] = freq_fft(param, eta)

Ta = param.Ta;
fs = param.fs;



y = fft(eta);           % Compute DFT of x
i = ifft(y);
n = length(y);          % length of signal (output), not sure why minus 1
A = 2*abs(y/n);         % Magnitude scaled by length
A(abs(y)<1e-6) = 0;
A(1) = A(1)/2;
phi = (angle(y));       % Phase
f = (0:n-1)*fs/n;       % Frequency vector

A = A(1:round(n/2));           % Use first half of outputs
phi = phi(1:round(n/2));
f = f(1:round(n/2));

% L = Ta*fs;          % length of signal
% L = length(eta);
% 
% f = fs*(0:(L/2))/L; % frequencies (Hz)
% 
% Y = fft(eta); % calculate fft
% 
% 
% a = abs(Y/L);       % magnitude of output divided by length of signal
% A = a(1:L/2+1);     % select first half of resulting signal, 
% A(2:end-1) = 2*A(2:end-1);  % double all but the first magnitude (DC)
% 
% phi = unwrap(angle(Y));             % find phase
% phi = phi(1:L/2+1);

% y = fft(eta);
% z = fftshift(y);
% 
% ly = length(y);
% f = (-ly/2:ly/2-1)/ly*fs;
% 
% tol = 1e-6;
% z(abs(z) < tol) = 0;
% 
% phi = angle(z);
% 
% A = abs(z/L);       % magnitude of output divided by length of signal
% A(f<0)=[];
% A(2:end-1) = 2*A(2:end-1);
% phi(f<0)=[];
% f(f<0)=[];



% % Threshold filtering on A, f, phi
% % TODO make this more robust
% c = 0.05;
% E = trapz(f, A); % total energy
% S = cumtrapz(f, A); % energy integral
% 
% R = S / E; % percent of total energy at each bin
% 
% [lo_val, lo_idx] = min(abs(R - c));
% [hi_val, hi_idx] = min(abs(R - (1-c)));
% A = A(lo_idx: hi_idx);
% f = f(lo_idx: hi_idx);
% phi = phi(lo_idx: hi_idx);

% Consider the wavenumber
w = f * 2*pi;
k = w.^2 / 9.81;