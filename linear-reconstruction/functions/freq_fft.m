function [stat, w, k, A, phi] = freq_fft(param, stat, eta)

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
w = f * 2*pi;

figure
hold on
plot(f, A)
yline(mu*max(A))

aa = A - mu*max(A);
aa(aa < 0) = 0;
zpos = find(~[0 aa' 0]);
[~, v] = max(diff(zpos));
lo_idx = zpos(v)+1;
hi_idx = zpos(v+1)-1;

stat.c_g1 = 9.81 / (w(lo_idx)*2);
stat.c_g2 = 9.81 / (w(hi_idx)*2);

% % Threshold filtering on A, f, phi
% % TODO make this more robust
% E = trapz(f, A); % total energy
% S = cumtrapz(f, A); % energy integral
% 
% R = S / E; % percent of total energy at each bin
% 
% [lo_val, lo_idx] = min(abs(R - mu));
% [hi_val, hi_idx] = min(abs(R - (1-mu)));
% 
% stat.c_g1 = 9.81 / (w(lo_idx)*2);
% stat.c_g2 = 9.81 / (w(hi_idx)*2);

% A = A(lo_idx: hi_idx);
% w = w(lo_idx: hi_idx);
% phi = phi(lo_idx: hi_idx);

% Consider the wavenumber
k = w.^2 / 9.81;