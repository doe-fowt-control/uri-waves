function [w, k, stat] = freq_range(eta_obs, param)
% eta_obs - raw observations
% param - parameters defined in linear_full.m

% Evaluate spectral density using Welch method
% window = length(eta_obs) -> # of windows used in Welch method,
% maximimized because more windows seems to make the result more specific
% (for regular waves)
% noverlap = (default) -> 50% of window size
% nfft = (default) -> max(256 or the closest power of 2 to the window size)

fs = param.fs;
mu = param.mu;
nf = param.nf;

% Set pwelch parameters
window = param.window;
noverlap = param.noverlap;
nfft = param.nfft;

% Calculate once to determine length
pxx1 = pwelch(eta_obs(:, 1), window, noverlap, nfft, fs);

nx = size(eta_obs, 2); % Number of wave gauges
npxx = length(pxx1); % Number of psd points

% Make empty array for averaging, append first psd
pxxt = ones(npxx, nx);
pxxt(:, 1) = pxx1;

% Iterate through remaining wave gauges, average all
for g = 2:1:nx
    [pxxt(:, g), f] = pwelch(eta_obs(:, g), window, noverlap, nfft, fs);
end

pxx = mean(pxxt, 2);

[w,k] = get_freqs(mu, nf, pxx, f);
[w1, k1] = get_freqs(mu, nf, pxxt(:,1), f);
[w6, k6] = get_freqs(mu, nf, pxxt(:,6), f);

% Calculate key wave statistics, store them as a structure called stat
stat = struct;

stat.w_hi_avg = max(w);
stat.w_lo_avg = min(w);

% high and low frequencies
stat.w_hi_pred = max(w6);
stat.w_lo_pred = min(w1);
% stat.w_lo_pred = w(5);

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
xlabel('Frequency (rad/s)')
ylabel('Power Density (m^2/rad/s)')

plot(f*2*pi, pxx)
plot(w, max(pxx)/2*ones(length(w)), 'kx')
xlim([0 max(w) * 1.1])
legend('PSD', 'Target Frequency')


function [w, k] = get_freqs(c, n, pxx, f)
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

end



end


