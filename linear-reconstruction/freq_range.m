function [w, k, stat] = freq_range(eta_obs, fs, c, n)
% fs - sampling frequency
% eta_obs - raw observations
% c - cutoff threshold for energy container
% n - number of frequencies to return

% Evaluate spectral density using Welch method
% window = length(eta_obs) -> # of windows used in Welch method,
% maximimized because more windows seems to make the result more specific
% (for regular waves)
% noverlap = (default) -> 50% of window size
% nfft = (default) -> max(256 or the closest power of 2 to the window size)

% Calculate PSD
% [pxx, f] = pwelch(eta_obs(:, 1), 128, 96,[], fs);
[pxx, f] = pwelch(eta_obs(:, 1), [], [], [], fs);

% Find where power is greater than some cutoff
thresh = pxx > max(pxx)*c;

% Frequency and power series where threshold is met
f_ = f(thresh);
pxx_ = pxx(thresh);

% Cumulative sum of area under PSD curve, normalized to be within 0-1
Q_ = cumtrapz(f_, pxx_) / trapz(f_, pxx_);

% Spline fit to cumsum (0-1) on horizontal, frequencies on vertical
pp = spline(Q_, f_);

% Evaluate spline fit at n linearly spaced points to get nonlinear spacing
% back. Multiply by 2*pi to get rad/s
w = 2*pi*ppval(pp, linspace(0,1,n));

if w(1) == 0
    w(1) = w(1) + 0.001;
end

% Calculate corresponding wave numbers with deep water dispersion relation
k = w.^2./9.81;

% Calculate key wave statistics, store them as a structure called stat
stat = struct;

% high and low frequencies
stat.w_hi = max(w);
stat.w_lo = min(w);

% peak period
pperiod = 1/(f(pxx == max(pxx)));
stat.pperiod = pperiod;

% zero-th moment as area under power curve
m0 = trapz(f, pxx);
stat.m0 = m0;

% significant wave height from zero moment
h_m0 = 4*sqrt(m0);
stat.h_m0 = h_m0;


figure
hold on
title('Wave Energy Spectrum and Targeted Frequencies')
xlabel('Frequency (Hz)')
ylabel('Power Density (m^2/Hz)')

plot(f, pxx)
plot(w/2/pi, max(pxx)/2*ones(length(w)), 'k|')
xlim([0 max(f(thresh)) * 1.1])
legend('PSD', 'Target Frequencies')



end


