function [m0, h_m0, h_var, pperiod] = spectral(eta_obs, fs)
% fs - sampling frequency
% eta_obs - raw observations

% m0 - zeroth moment, area under spectral curve
% h_m0 - significant wave height based on zeroth moment
% h_var - signiciant wave height calculated using variance
% pperiod - peak period

% Calculate PSD
[pxx, f] = pwelch(eta_obs(:, 1), [], [],[], fs);
% figure()
%     plot(f,pxx)
%     title('Wave Energy Spectrum')
%     set(gcf,'color','w');

% peak period
pperiod = 1/(f(pxx == max(pxx)));

% zero-th moment as area under power curve
m0 = trapz(f, pxx);

% significant wave height from zero moment
h_m0 = 4*sqrt(m0);


% signicifant wave height from variance averaged over each wave guage
h_var = 4*sqrt(mean(var(eta_obs)));


end


