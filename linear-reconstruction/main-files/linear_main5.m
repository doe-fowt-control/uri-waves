%% Shawn Albertson 2/16/22

% Perform reconstruction using a single probe using FFT and calculate
% propagation error across multiple gauges

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'
% load '../data/mat/12.10.21/D.mat'

[pram, stat] = make_structs;

pram.fs = 32;          % sampling frequency
pram.mg = 6;           % measurement gauges
pram.window = 25;       % number of seconds outside of prediction to use for visualization


% Preprocess to get spatiotemporal points and resampled observations
[time, eta] = preprocess_1g(pram, data, time, x);

pram.tr = 60;
stat = spectral_1g(pram, stat, eta);

fprintf(['slow: ' num2str(stat.c_g2) ' - '])
fprintf(['fast: ' (num2str(stat.c_g1)) '\n'])

t_list = 60:20:140;
for ti = 1:1:length(t_list)
    pram.tr = t_list(ti);

    % Select subset of data for remaining processing
    stat = subset_1g(pram, stat, time);
    
    % Find frequency, wavenumber, amplitude, phase
    stat = decompose_1g(pram, stat, eta);
    
    % List index of gauges to predict at
    x_pred = [1,2,3,4,5,6,7];
    
    for xi = 1:1:length(x_pred)
        pram.pg = x_pred(xi);

        % Propagate to new space / time region
        [t, r, stat] = reconstruct_for_prediction_region(pram, stat, x, time);
        
        % Get corresponding measured data
        p = eta(stat.i1 - pram.window * pram.fs:stat.i2 + pram.window * pram.fs + 1, pram.pg);

        e = abs(r-p) / stat.Hs;

        e_list(:, xi) = e;
    
    end
    E(:, :, ti) = e_list;
end


ee = (mean(E, 3));

figure
hold on
d = 1;
xd = linspace(min(x(x_pred)) - d, max(x(x_pred)) + d, 300);
i_list = ones(1, length(x_pred));
for xi = 1:1:length(x_pred)
    i_list(xi) = find(abs(x(x_pred(xi)) - xd) == min(abs(x(x_pred(xi)) - xd)));
end

C = zeros(length(t), length(xd));
C(:, i_list) = ee;
for id = 1:1:3
    C(:, i_list - id) = ee;
    C(:, i_list + id) = ee;
end

imagesc(xd, t, C)
set(gca,'YDir','normal') 
colorbar
colormap(flipud(gray))


a = 0;
b = max(x(x_pred)) + a;
c = min(x(x_pred)) * 0;
plot([c b], [1/stat.c_g2 * c 1/stat.c_g2 * b], 'r-')
plot([c b], [pram.Ta+1/stat.c_g1 * c pram.Ta+ 1/stat.c_g1 * b], 'r-')
xline(x(x_pred), 'k:')

xlabel('location (m)')
ylabel('time (s)')
title('Misfit at measured locations compared with evaluated prediction zone')

ylim([-5 pram.Ta+pram.window - 5])
