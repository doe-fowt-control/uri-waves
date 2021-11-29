function [w] = freq_range(eta_obs, fs, c, n)
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
[pxx, f] = pwelch(eta_obs(:, 1), length(eta_obs), [],[], fs);

% Find where power is greater than some cutoff
thresh = pxx > max(pxx)*c;

% Isolate the minimum and maximum frequencies within this threshold
lo = min(f(thresh));
hi = max(f(thresh));

% Create a linear array of frequencies
f = linspace(lo, hi, n);

% convert to rad/s
w = 2*pi*f;


