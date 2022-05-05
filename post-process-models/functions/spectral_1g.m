function stat = spectral(pram, stat, eta_)
% stat.[c_g1, c_g2, pperiod, Hs, m0]

fs = pram.fs;
mg = pram.mg;
mu = pram.mu;
tr = pram.tr;
ts = pram.ts;
wwindow = pram.wwindow;
noverlap = pram.noverlap;
nfft = pram.nfft;

% indices for spectral acquisition
si1 = round((tr - ts)) * fs;
si2 = round(tr) * fs;

% PSD
% [pxx, f] = pwelch(eta_(si1:si2, mg), wwindow, noverlap, nfft, fs);

% Calculate once to determine length
[pxx, f] = pwelch(eta_(si1:si2, mg), wwindow, noverlap, nfft, fs);

w = 2*pi*f;

% plot(f, pxx, 'LineWidth',1.5)
% xlim([0 15])


% Threshold filtering on A, f, phi
% TODO make this more robust
E = trapz(w, pxx); % total energy
S = cumtrapz(w, pxx); % energy integral

R = S / E; % percent of total energy at each bin

[~, lo_idx] = min(abs(R - mu));
[~, hi_idx] = min(abs(R - (1-mu)));


% % Find continuous region above threshold
% aa = pxx - mu*max(pxx);
% aa(aa < 0) = 0;
% zpos = find(~[0 aa' 0]);
% [~, v] = max(diff(zpos));
% lo_idx = zpos(v);
% hi_idx = zpos(v+1)-1;

% Calculate group velocities
stat.c_g1 = 9.81 / (w(lo_idx)*2);
stat.c_g2 = 9.81 / (w(hi_idx)*2);

% peak period
stat.pperiod = 1/(f(pxx == max(pxx)));

% zero-th moment as area under power curve
stat.m0 = trapz(f, pxx);

% significant wave height from zero moment
stat.Hs = 4*sqrt(stat.m0);