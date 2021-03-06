function stat = spectral(pram, stat)
% stat.[c_g1, c_g2, pperiod, Hs, m0]

eta = stat.eta;
x = stat.x;

fs = pram.fs;
mg = pram.mg;
mu = pram.mu;
wwindow = pram.wwindow;
noverlap = pram.noverlap;
nfft = pram.nfft;

% indices for spectral acquisition
si1 = stat.si1;
si2 = stat.si2;

if length(mg) ~= 1

    % Calculate PSD as average for every wave gauge
    [pxx1, f] = pwelch(eta(si1:si2, mg(1)), wwindow, noverlap, nfft, fs);
    
    nx = length(mg);        % number of wave gauges used for measurement
    npxx = length(pxx1);    % number of psd points
    
    % Make empty array for averaging, append first psd
    pxxt = ones(npxx, nx);
    pxxt(:, 1) = pxx1;
    
    % Iterate through remaining wave gauges, average all
    
    for g = 2:1:nx
        [pxxt(:, g), f] = pwelch(eta(si1:si2, mg(g)), wwindow, noverlap, nfft, fs);
    end
    
    pxx = mean(pxxt, 2);
    w = 2*pi*f;

elseif length(mg) == 1
    % Calculate once

    [pxx, f] = pwelch(eta(si1:si2, mg), wwindow, noverlap, nfft, fs);
    w = 2*pi*f;

end

% Find group velocities as percentage of peak energy
aa = pxx - mu*max(pxx);
aa(aa < 0) = 0;
zpos = find(~[0 aa' 0]);
[~, v] = max(diff(zpos));
lo_idx = zpos(v);
hi_idx = zpos(v+1)-1;

stat.w_spec = w;
stat.pxx = pxx;

% Calculate group velocities
stat.c_g1 = 9.81 / (w(lo_idx)*2);
stat.c_g2 = 9.81 / (w(hi_idx)*2);

if length(mg) ~= 1
    % calculate wavenumber bandwidth for reconstruction
    stat.xe = max(x(mg)) + pram.Ta * stat.c_g2;
    stat.xb = min(x(mg));
    
    stat.k_min = 2*pi/(stat.xe - stat.xb);
    stat.k_max = pi/min(abs(diff(x))) * 2;
end

% peak period
stat.pperiod = 1/(f(pxx == max(pxx)));

% peak wavelength
stat.k_p = (1/9.81) * (2*pi/stat.pperiod)^2;

% zero-th moment as area under power curve
stat.m0 = trapz(f, pxx);

% significant wave height from zero moment
stat.Hs = 4*sqrt(stat.m0);


% % method to find group velocities by integrating energy under curve 
% E = trapz(w, pxx); % total energy
% S = cumtrapz(w, pxx); % energy integral
% 
% R = S / E; % percent of total energy at each bin
% 
% % indices for frequency selection
% [~, lo_idx] = min(abs(R - mu));
% [~, hi_idx] = min(abs(R - (1-mu)));

