%% Shawn Albertson 4/6/22

% Reconstruction using `n` probes
% Plot reconstruction at prediction gauge

clear

addpath '/Users/shawnalbertson/Documents/Research/wave-models/uri-waves/post-process-models/functions'

load '../data/mat/12.10.21/D.mat'

[pram, stat] = make_structs;

pram.x = x;
pram.mg = 3:6;
pram.pg = 2;
pram.lam = 10;
pram.nf = 100;

% Preprocess to get spatiotemporal points and resampled observations
stat = preprocess(pram, stat, data, time, x);

% Select subset of data for remaining processing
stat = subset(pram, stat);

stat = spectral(pram, stat);

% Find frequency, wavenumber, amplitude, phase
stat = inversion_lin(pram, stat);
stat = inversion_cwm(pram, stat);

[t_rec, r, stat] = reconstruct(pram, stat, 0);

% designate measured signal as p
p = stat.eta(stat.vi1: stat.vi2, pram.pg);




figure
hold on
plot((t_rec - pram.tr) ./ stat.pperiod, r ./ stat.Hs, 'linewidth', 1)
plot((t_rec - pram.tr) ./ stat.pperiod, p ./ stat.Hs, 'linewidth', 1)
xline((pram.tr - pram.tr) ./ stat.pperiod, 'k--', 'linewidth', 1) % reconstruction time
xline((stat.t_min - pram.Ta) ./ stat.pperiod, 'k', 'linewidth', 2)
xline((stat.t_max - pram.Ta) ./ stat.pperiod, 'k', 'linewidth', 2)
xlim([(stat.t_min - pram.Ta) ./ stat.pperiod - stat.pperiod * 3 ...
    (stat.t_max - pram.Ta) ./ stat.pperiod + stat.pperiod * 3 ...
    ]);
ax = gca;
ylim_val = 2*max(p ./ stat.Hs);
ylim([-ylim_val ylim_val])
xticks(sort([ax.XAxis.TickValues, round((stat.t_max - pram.tr) ./ stat.pperiod, 2)]))

legend('prediction', ...
    'measurement', ...
    'reconstruction time', ...
    'prediction zone', ...
    'location', 'northwest' ...
    );
xlabel('time ( t / T_p )')
ylabel('amplitude ( m / H_s )')
title('Wave prediction using five gauges compared with measurement')





