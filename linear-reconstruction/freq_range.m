function [w] = freq_range(eta_obs, fs, c, n)
% fs - sampling frequency
% eta_obs - raw observations
% c - cutoff threshold for energy container
% n - number of frequencies to return

% Evaluate spectral density using Welch method
% window = length(eta_obs) -> # of windows used in Welch method,
% maximimized because more windows seems to make the result more specific
% (for regular waves)
% noverlap = [] -> default to 50% of window size

[pxx, f] = pwelch(eta_obs(:, 1), length(eta_obs), [],[], fs);

thresh = pxx > max(pxx)*c;

% Finally isolate the minimum and maximum frequencies, create a linear
% array
lo = min(f(thresh));
hi = max(f(thresh));
f = linspace(lo, hi, n);

% convert to rad/s
w = 2*pi*f;


