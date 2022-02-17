%% Shawn Albertson
% Published: 2/15/21
% Updated:   2/15/21

% Perform reconstruction using a single probe using FFT and calculate
% propagation error across multiple gauges

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'
% load '../data/mat/12.10.21/D.mat'

param = struct;
param.fs = 32;          % sampling frequency
param.Ta = 30;          % reconstruction assimilation time
param.mu = .05;         % cutoff parameter
param.mg = 6;           % measurement gauges
param.window = 25;       % number of seconds outside of prediction to use for visualization

mg = param.mg;
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;
window = param.window;

stat = struct;

% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta] = preprocess(param, data, time, x);

t_list = 60:20:140;


for ti = 1:1:length(t_list)
    param.tr = t_list(ti);

    % Select subset of data for remaining processing
    stat = subset2(param, stat, T);
    
    % Find frequency, wavenumber, amplitude, phase
    stat = freq_fft(param, stat, eta);
    fprintf(['-' num2str(stat.c_g2) '-'])

    x_lab = [2,3,4,5,6];
    x_pred = [7,5,4,3,2,1];
    
    for xi = 1:1:length(x_pred)
        param.pg = x_pred(xi);

        % Propagate to new space / time region
        [r, t, stat] = reconstruct_slice_fft(param, stat, x);
        
        % Get corresponding measured data
        p = eta(stat.i1 - window * fs:stat.i2 + window * fs +1, param.pg);
    
%         e = abs((r-p).^2) / (2 * var(eta(stat.i1:stat.i2, param.mg)));

        e = (r-p).^2;
        
        e_list(:, xi) = e;
    
    end
    E(:, :, ti) = e_list;
end

stat.c_g2 = 0.6329;

ee = sqrt(mean(E, 3));

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
plot([c b], [Ta+1/stat.c_g1 * c Ta+ 1/stat.c_g1 * b], 'r-')
xline(x(x_pred), 'k:')

xlabel('location (m)')
ylabel('time (s)')
title('Error at measured locations compared with evaluated prediction zone')
