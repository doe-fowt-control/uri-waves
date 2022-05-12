%% Shawn Albertson 5/12/22

% Full wave model evaluated at a single instance
% Optionally change the number of wave gauges used and inversion techniques

clear

addpath '/Users/shawnalbertson/Documents/Research/wave-models/uri-waves/post-process-models/functions'

load '../data/mat/12.10.21/D.mat'

[pram, stat] = make_structs;

pram.mg = 2:3;
pram.pg = 1;

% Preprocess to get spatiotemporal points and resampled observations
stat = preprocess(pram, stat, data, time, x);

% Select subset of data for remaining processing
stat = subset(pram, stat);

% Spectral calculations
stat = spectral(pram, stat);

% Inversion
stat = inversion_lin(pram, stat);
stat = inversion_cwm(pram, stat);

% Reconstruct at prediction gauge at adjustable time-frame 
[t_rec, r, stat] = reconstruct(pram, stat, 0);

% Measured signal to compare with reconstruction
p = stat.eta(stat.vi1: stat.vi2, pram.pg)';

% Plot results
if length(pram.mg) ~= 1
    shift = pram.tr;
elseif length(pram.mg) == 1
    shift = pram.Ta;
end


% Plot single instance of measurement and prediction
figure
hold on
plot((t_rec - shift) ./ stat.pperiod, r ./ stat.Hs, 'linewidth', 1)
plot((t_rec - shift) ./ stat.pperiod, p ./ stat.Hs, 'linewidth', 1)
xline(0, 'k--', 'linewidth', 1) % reconstruction time
xline((stat.t_min - pram.Ta) ./ stat.pperiod, 'k', 'linewidth', 2)
xline((stat.t_max - pram.Ta) ./ stat.pperiod, 'k', 'linewidth', 2)
xlim([(stat.t_min - pram.Ta) ./ stat.pperiod - stat.pperiod * 1 ...
    (stat.t_max - pram.Ta) ./ stat.pperiod + stat.pperiod * 1 ...
    ]);
ax = gca;
ylim_val = 2*max(p ./ stat.Hs);
ylim([-ylim_val ylim_val])
% add tick mark for future prediction
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

% Plot misfit epsilon for single instance
figure
plot(t_rec - shift, abs(r-p)/stat.Hs, 'b', 'linewidth', 0.5)
xline(0, 'k--', 'linewidth', 1) % reconstruction time
xline(stat.t_min - pram.Ta, 'k-', 'linewidth', 2)
xline(stat.t_max - pram.Ta, 'k-', 'linewidth', 2)
legend('error', 'reconstruction time', 'prediction zone')
ylim([0 1])
xlabel('time (s)')
ylabel('absolute difference')
title('Error')

