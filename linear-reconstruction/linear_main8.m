%% Shawn Albertson 4/6/22

% Reconstruction using `n` probes
% Plot reconstruction at prediction gauge

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/12.10.21/D.mat'

[pram, stat] = make_structs;

pram.x = x;
pram.mg = 2:6;


% Preprocess to get spatiotemporal points and resampled observations
[X, T, t, eta] = preprocess_ng(pram, data, time, x);

% Select subset of data for remaining processing
stat = subset_ng(pram, stat, t);

stat = spectral_ng(pram, stat, eta);

% Find frequency, wavenumber, amplitude, phase
stat = decompose_ng(pram, stat, X, T, eta);

pram.pg = 1;
[t_rec, r, stat] = reconstruct_ng(pram, stat, x, t);

% designate measured signal as p
p = eta(stat.vi1: stat.vi2, pram.pg);

figure
hold on
plot((t_rec - pram.tr) ./ stat.pperiod, r ./ stat.Hs, 'linewidth', 1)
plot((t_rec - pram.tr) ./ stat.pperiod, p ./ stat.Hs, 'linewidth', 1)
xline((pram.tr - pram.tr) ./ stat.pperiod, 'k--', 'linewidth', 1) % reconstruction time
xline((stat.t_min - pram.tr) ./ stat.pperiod, 'k', 'linewidth', 2)
xline((stat.t_max - pram.tr) ./ stat.pperiod, 'k', 'linewidth', 2)
xlim([(stat.t_min - pram.tr) ./ stat.pperiod - stat.pperiod * 3 ...
    (stat.t_max - pram.tr) ./ stat.pperiod + stat.pperiod * 3 ...
    ]);
ax = gca;
ylim_val = 2*max(p ./ stat.Hs);
ylim([-ylim_val ylim_val])
% xticks(sort([ax.XAxis.TickValues, round((stat.t_max - pram.tr) ./ stat.pperiod, 2)]))

legend('prediction', ...
    'measurement', ...
    'reconstruction time', ...
    'prediction zone', ...
    'location', 'northwest' ...
    );
xlabel('time ( t / T_p )')
ylabel('amplitude ( m / H_s )')
title('Wave prediction using five gauges compared with measurement')




