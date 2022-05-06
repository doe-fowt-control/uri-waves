%% Shawn Albertson 2/9/22

% Perform reconstruction using a single probe using FFT
% Optionally plot the error between the wave propagation and measurement
% Optionally visualize reconstruction and reconstruction error


clear

addpath '/Users/shawnalbertson/Documents/Research/wave-models/uri-waves/post-process-models/functions'

% load '../data/mat/3.21.22/B.mat'
load '../data/mat/12.10.21/D.mat'

[pram, stat] = make_structs;

% % calibration
% load '../data/mat/3.21.22/cal.mat'
% pram.slope = cal(1, :);
% pram.intercept = cal(2,:);

pram.mg = 2;
pram.pg = 1;

tr = pram.tr;            % initial time (s)
Ta = pram.Ta;             % assimilation time (s)
fs = pram.fs;
window = pram.window;


% Preprocess to get spatiotemporal points and resampled observations
[t, eta] = preprocess_1g(pram, data, time, x);

stat = spectral_1g(pram, stat, eta);

% Select subset of data for remaining processing
stat = subset_1g(pram, stat, t);

% Find frequency, wavenumber, amplitude, phase
stat = decompose_1g(pram, stat, eta);

% % Check that reconstruction worked (create plots)
% check_reconstruction(pram, stat, eta)

% Propagate to new space / time region
[t_rec, r, stat] = reconstruct_for_prediction_region(pram, stat, x, t);

% Unpack time values for prediction window
t_min = stat.t_min;
t_max = stat.t_max;

% Get corresponding measured data
p = eta(stat.i1 - window * fs:stat.i2 + window * fs +1, pram.pg);

% % Use new functions (someday)
% [t_rec, r, stat] = reconstruct_1g(pram, stat, x, t);
% p = eta(stat.vi1:stat.vi2, pg);

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

xlim([(stat.t_min - pram.Ta) ./ stat.pperiod - stat.pperiod * 3 ...
    (stat.t_max - pram.Ta) ./ stat.pperiod + stat.pperiod * 3 ...
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
title('Prediction at gauge 6 using measurement from gauge 3')

% subplot(2,1,2)
% plot(t, abs(r-p), 'r')
% xline(t_min, 'k-', 'linewidth', 1)
% xline(t_max, 'k-', 'linewidth', 1)
% % ylim([0 1])
% legend('error', 'prediction zone')
% xlabel('time (s)')
% ylabel('absolute difference')
% title('Error')





