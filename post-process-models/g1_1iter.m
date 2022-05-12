%% Shawn Albertson 4/6/22

% Reconstruction using `1` probe
% Plot reconstruction at prediction gauge for single instance

clear

addpath '/Users/shawnalbertson/Documents/Research/wave-models/uri-waves/post-process-models/functions'

load '../data/mat/12.10.21/D.mat'

[pram, stat] = make_structs;
stat = preprocess(pram, stat, data, time, x);
stat = subset(pram, stat);
stat = spectral(pram, stat);
stat = inversion_lin(pram, stat);
stat = inversion_cwm(pram, stat);
[t_rec, r, stat] = reconstruct(pram, stat, 0);
p = stat.eta(stat.vi1: stat.vi2, pram.pg);


figure
hold on
if length(pram.mg) ~= 1
    shift = pram.tr;
elseif length(pram.mg) == 1
    shift = pram.Ta;
end
plot((t_rec - shift) ./ stat.pperiod, r ./ stat.Hs, 'linewidth', 1)
plot((t_rec - shift) ./ stat.pperiod, p ./ stat.Hs, 'linewidth', 1)
xline(0, 'k--', 'LineWidth', 1)

xline((stat.t_min - pram.Ta) ./ stat.pperiod, 'k-', 'linewidth', 2)
xline((stat.t_max - pram.Ta) ./ stat.pperiod, 'k-', 'linewidth', 2)

xlim([(stat.t_min - pram.Ta) ./ stat.pperiod - stat.pperiod * 1 ...
    (stat.t_max - pram.Ta) ./ stat.pperiod + stat.pperiod * 1 ...
    ]);
ax = gca;
xticks(sort([ax.XAxis.TickValues, round((stat.t_max - pram.Ta) ./ stat.pperiod, 2)]))
ylim_val = 2*max(p ./ stat.Hs);
ylim([-ylim_val ylim_val])
legend('prediction', ...
    'measurement', ...
    'reconstruction time', ...
    'prediction zone boundary', ...
    'Location', 'northwest'...
    )
xlabel('time ( t / T_p )')
ylabel('amplitude ( m / H_s )')
title('Prediction at gauge 6 using measurement from gauge 5')



