%% Shawn Albertson 4/6/22

% Reconstruction using `1` probe
% Plot reconstruction at prediction gauge for single instance

clear

addpath '/Users/shawnalbertson/Documents/Research/wave-models/uri-waves/post-process-models/functions'

load '../data/mat/12.10.21/D.mat'

[pram, stat] = make_structs;

pram.x = x;
pram.mg = 2;
pram.pg = 1;
pram.window = 2;


% % calibration
% load '../data/mat/3.21.22/cal.mat'
% pram.slope = cal(1, :);
% pram.intercept = cal(2,:);


% Preprocess to get spatiotemporal points and resampled observations
[t, eta] = preprocess_1g(pram, data, time, x);

% Select subset of data for remaining processing
stat = subset_1g(pram, stat, t);

stat = spectral_1g(pram, stat, eta);

% Find frequency, wavenumber, amplitude, phase
stat = decompose_1g(pram, stat, eta);

[t_rec, r, stat] = reconstruct_1g(pram, stat, x, t);

p = eta(stat.vi1: stat.vi2, pram.pg);

figure
% subplot(2,1,1)
hold on
% plot(t_rec ./ stat.pperiod, r ./ stat.Hs, 'linewidth', 1)
% plot(t_rec ./ stat.pperiod, p ./ stat.Hs, 'linewidth', 1)
% xline(pram.Ta ./ stat.pperiod, 'k--', 'LineWidth', 1)
% xline(stat.t_min ./ stat.pperiod, 'k-', 'linewidth', 1)
% xline(stat.t_max ./ stat.pperiod, 'k-', 'linewidth', 1)

plot((t_rec - pram.Ta) ./ stat.pperiod, r ./ stat.Hs, 'linewidth', 1)
plot((t_rec - pram.Ta) ./ stat.pperiod, p ./ stat.Hs, 'linewidth', 1)
xline((pram.Ta - pram.Ta) ./ stat.pperiod, 'k--', 'LineWidth', 1)
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

% subplot(2,1,2)
% plot(t, abs(r-p), 'r')
% xline(t_min, 'k-', 'linewidth', 1)
% xline(t_max, 'k-', 'linewidth', 1)
% % ylim([0 1])
% legend('error', 'prediction zone')
% xlabel('time (s)')
% ylabel('absolute difference')
% title('Error')


% figure
% hold on
% plot(t_rec - pram.Ta, r)
% plot(t_rec - pram.Ta, p)
% xline(0, 'k--')  % reconstruction time
% xline(stat.t_min - pram.Ta)
% xline(stat.t_max - pram.Ta)
% 
% legend('prediction', 'measurement', 'reconstruction time', 'prediction zone')
% xlabel('time (s)')
% ylabel('amplitude (m)')
% title('Wave forecast and measurement')
% 




