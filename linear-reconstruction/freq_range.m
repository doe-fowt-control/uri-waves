function [w] = freq_range(eta_obs, fs, c, n, method)
% fs - sampling frequency
% eta_obs - raw observations
% c - cutoff threshold for energy container
% n - number of frequencies to return
% method - 
    % 0 uses regular linear spacing
    % 1 creates higher density spacing near values of importance

% Evaluate spectral density using Welch method
% window = length(eta_obs) -> # of windows used in Welch method,
% maximimized because more windows seems to make the result more specific
% (for regular waves)
% noverlap = (default) -> 50% of window size
% nfft = (default) -> max(256 or the closest power of 2 to the window size)

% Calculate PSD
[pxx, f] = pwelch(eta_obs(:, 1), 1024, [],[], fs);

% Find where power is greater than some cutoff
thresh = pxx > max(pxx)*c;

% new frequency and power series within this range
f_ = f(thresh);
pxx_ = pxx(thresh);

lo = min(f_);
hi = max(f_);

Q_ = cumtrapz(f_, pxx_) / trapz(f_, pxx_);

pp = spline(Q_, f_);

w = 2*pi*ppval(pp, linspace(0,1,n));

1+1;

% if method == 0
% % % uncomment here to get og method back
%     % Isolate the minimum and maximum frequencies within this threshold
%     lo = min(f(thresh));
%     hi = max(f(thresh));
%     
%     % Create a linear array of frequencies
%     f = linspace(lo, hi, n);
%     
%     % convert to rad/s
%     w = 2*pi*f;
% end
% 
% if method == 1
%     frel = f(thresh);
%     lo = min(frel);
%     hi = max(frel);
%     
%     smallest_change = (hi-lo)./(3*n);
%     size_norm = pxx(thresh)/max(pxx(thresh)); % large value for frequencies of importance
%     increment = smallest_change.*(1./size_norm); 
%     
%     
%     j = 1;
%     fdist = [lo];
%     for i = 1:length(frel)-1
%         while fdist(j) < frel(i+1) - (frel(i+1)-frel(i))/2
%             fdist(j+1) = fdist(j) + increment(i);
%             j = j+1;
%         end
%     end
% 
%     w = 2*pi*fdist;
% end




