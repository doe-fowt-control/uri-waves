%% Shawn Albertson 3/1/22

% Reconstruction using `1` probe
% Plot reconstruction at prediction gauges for multiple instances
clear

addpath '/Users/shawnalbertson/Documents/Research/wave-models/uri-waves/post-process-models/functions'

% load '../data/mat/3.21.22/B.mat'
load '../data/mat/12.10.21/D.mat'

% Initialize according to values in make_structs function
[pram, stat] = make_structs;

pram.mg = 6;           % measurement gauge(s)
pram.fs = 32;
pram.window = 10;

% % calibration
% load '../data/mat/3.21.22/cal.mat'
% pram.slope = cal(1, :);
% pram.intercept = cal(2,:);


% Preprocess to get spatiotemporal points and resampled observations
stat = preprocess(pram, stat, data, time, x);

pram.tr = 60;
stat = subset(pram, stat);
stat = spectral(pram, stat);

t = stat.t;
eta = stat.eta;
x = stat.x;

t_list = 60:20:140;
% List index of gauges to predict at
x_pred = [1,2,3,4,5,6];

misfit = zeros([length(t_list), length(x_pred)]);

% iterate across realizations
for ti = 1:1:length(t_list)
    pram.tr = t_list(ti);

    % Select subset of data for remaining processing
    stat = subset(pram, stat);
    
    % Find frequency, wavenumber, amplitude, phase
    stat = decompose_1g(pram, stat);
   
    % iterate across locations
    for xi = 1:1:length(x_pred)
        pram.pg = x_pred(xi);

        % Propagate to new space / time region
        [t_rec, r, stat] = reconstruct_1g(pram, stat, 1);

        % Get corresponding measured data
        p = stat.eta(stat.i1 - pram.window * pram.fs:stat.i2 + pram.window * pram.fs + 1, pram.pg)';

        % isolate regions within prediction zone to find error
        r_pred = r(stat.rpi1:stat.rpi2);
        p_pred = stat.eta(stat.pi1:stat.pi2, pram.pg)';

        e_pred = abs(p_pred - r_pred) / stat.Hs;

        % mean misfit for single realization, single location
        % need one for all locations/ realizations
        misfit(ti, xi) = mean(e_pred);

        e_vis = abs(r-p) / stat.Hs;
        e_list_vis(:, xi) = e_vis;
    
    end

    E(:, :, ti) = e_list_vis;
end

mean_misfit = mean(misfit);

ee_vis = (mean(E, 3));

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
C = zeros(length(t_rec), length(xd));
C(:, i_list) = ee_vis;

% make bars wider
for id = 1:1:3
    C(:, i_list - id) = ee_vis;
    C(:, i_list + id) = ee_vis;
end

stat.plamb = 9.81 * stat.pperiod^2 / 2 / pi;

pperiod = stat.pperiod;
% pperiod = 1.132;
plamb = stat.plamb;
c_g1 = stat.c_g1;
c_g2 = stat.c_g2;
Ta = pram.Ta;

% imagesc plot scaled by peak period and peak wavelength
imagesc(xd./plamb, t_rec./pperiod, C, [0, 0.5])
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

ylim([-3 15])