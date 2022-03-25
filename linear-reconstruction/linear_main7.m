%% Shawn Albertson
% Published: 2/16/21
% Updated:   2/17/21

% Perform reconstruction using a single probe using FFT
% compare calculated prediction zone with apparent prediction zone based on
% error
% use data from barge experiment 2/18/22

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/3.21.22/B.mat'

load '../data/mat/3.21.22/cal.mat'

pram = struct;  % input parameters
stat = struct;  % calculated statistics

% reconstruction parameters
pram.fs = 32;          % sampling frequency
pram.Ta = 5;          % reconstruction assimilation time
pram.mu = .05;         % cutoff parameter
pram.mg = 1;           % measurement gauges
pram.window = 25;       % number of seconds outside of prediction to use for visualization

% spectral parameters
pram.ts = 30;           % spectral assimilation time
pram.wwindow = [];      % pwelch window
pram.noverlap = [];    % pwelch noverlap
pram.nfft = 4096;        % pwelch nfft

mg = pram.mg;
Ta = pram.Ta;             % assimilation time (s)
fs = pram.fs;
window = pram.window;

% calibration
pram.slope = -s(1, :);
pram.intercept = s(2,:);


% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta] = preprocess(pram, data, time, x);



x = x - min(x);

pram.tr = 60;
stat = spectral(pram, stat, eta);

fprintf(['slow: ' num2str(stat.c_g2) ' - '])
fprintf(['fast: ' (num2str(stat.c_g1)) '\n'])

t_list = 60:20:140;
for ti = 1:1:length(t_list)
    pram.tr = t_list(ti);

    % Select subset of data for remaining processing
    stat = subset2(pram, stat, T);
    
    % Find frequency, wavenumber, amplitude, phase
    stat = decompose(pram, stat, eta);
    
    % List index of gauges to predict at
    x_pred = [1,2,3,4];
    
    for xi = 1:1:length(x_pred)
        pram.pg = x_pred(xi);

        % Propagate to new space / time region
        [r, t, stat] = reconstruct_slice_fft(pram, stat, x);
        
        % Get corresponding measured data
        p = eta(stat.i1 - window * fs:stat.i2 + window * fs + 1, pram.pg);

        e = abs(r-p) / stat.Hs;

        e_list(:, xi) = e;
    
    end
    E(:, :, ti) = e_list;
end

ee = (mean(E, 3));

figure
hold on

% make horizontal axis array (space)
d = 1;
xd = linspace(min(x(x_pred)) - d, max(x(x_pred)) + d, 200);

% initialize horizontal index list
i_list = ones(1, length(x_pred));

% find indices for horizontal array to plot error
for xi = 1:1:length(x_pred)
    i_temp = find(abs(x(x_pred(xi)) - xd) == min(abs(x(x_pred(xi)) - xd)));

    % account for finding multiple indices
    if length(i_temp) > 1
        i_temp = i_temp(1);
    end
    i_list(xi) = i_temp;
end

% create 2D array for error vis
C = zeros(length(t), length(xd));
C(:, i_list) = ee;

% make bars wider
for id = 1:1:3
    C(:, i_list - id) = ee;
    C(:, i_list + id) = ee;
end

stat.plamb = 9.81 * stat.pperiod^2 / 2 / pi;

pperiod = stat.pperiod;
plamb = stat.plamb;
c_g1 = stat.c_g1;
c_g2 = stat.c_g2;

% imagesc plot scaled by peak period and peak wavelength
imagesc(xd./plamb, t./pperiod, C, [0, 0.5])
set(gca,'YDir','normal') 
colorbar
colormap(flipud(gray))

b = max(x(x_pred));
c = min(x(x_pred));
plot([0 b / plamb], [0, (1/c_g2 * plamb / pperiod) * b / plamb], 'r-')
plot([0 b / plamb], [Ta/pperiod, (Ta / pperiod) + (1/c_g1 * plamb / pperiod) * (b / plamb)], 'r-')

xline(x(x_pred)./plamb, 'k:')

xlabel('x / \lambda_p')
ylabel('t / T_p')
title('Misfit for steepness 2%')

ylim([-1 25])

% lower_prediction_limits = (1/c_g2 * plamb / pperiod) * x(x_pred) / plamb;
% higher_prediction_limits = (Ta / pperiod) + (1/c_g1 * plamb / pperiod) * (x(x_pred) / plamb);
% 
% lo_index_list = ones(1, length(x_pred));
% hi_index_list = ones(1, length(x_pred));
% 
% for i = 1:1:length(x_pred)
%     lower_index_temp = find( abs(lower_prediction_limits(i) - t) == min(abs(lower_prediction_limits(i) - t)) );
%     % account for finding multiple indices
%     if length(lower_index_temp) > 1
%         lower_index_temp = lower_index_temp(1);
%     end
%     lo_index_list(i) = lower_index_temp;
% 
%     hi_index_temp = find( abs(higher_prediction_limits(i) - t) == min(abs(higher_prediction_limits(i) - t)) );
%     % account for finding multiple indices
%     if length(hi_index_temp) > 1
%         hi_index_temp = hi_index_temp(1);
%     end
%     hi_index_list(i) = hi_index_temp;
% end
% 
% mean_prediction_error_list = ones(1, length(x_pred));
% for i = 1:1:length(x_pred)
%     mean_prediction_error_list(i) = mean(ee(lo_index_list(i):hi_index_list(i), i));
% end