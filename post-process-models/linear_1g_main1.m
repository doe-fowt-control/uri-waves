%% Shawn Albertson 2/9/22

% Perform reconstruction using a single probe using FFT
% Evaluate the error between the wave propagation and measurement across
% full time series

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'

[pram, stat] = make_structs;
pram.fs = 32;
pram.mg = 2;
pram.pg = 1;
pram.window = 1;

% Preprocess to get spatiotemporal points and resampled observations
[t, eta] = preprocess_1g(pram, data, time, x);

t_list = t(40 * pram.fs : 100 * pram.fs);
e_list = ones(length(t_list), 1);

for ti = 1:1:length(t_list)

    pram.tr = t_list(ti);
    pram.pt = round(pram.tr * pram.fs); % index of prediction time
    
    % Select subset of data for remaining processing
    stat = subset_1g(pram, stat, t);

    stat = spectral_1g(pram, stat, eta);

    stat = decompose_1g(pram, stat, eta);
    
    % Reconstruct
    [t_rec, r, stat] = reconstruct_for_prediction_region(pram, stat, x, t);
    
    % Unpack time values for prediction window
    t_min = stat.t_min;
    t_max = stat.t_max;
    
    % Get corresponding measured data
    p = eta(stat.i1 - pram.window * pram.fs: stat.i2 + pram.window * pram.fs + 1)';
    
    % Normalized root mean square error
    e = rmse(r, p, stat);

    e_list(ti) = e;
end

plot(t_list, e_list)
xlabel('time (s)')
ylabel('rmse')
title('evolution of rms error over time')
