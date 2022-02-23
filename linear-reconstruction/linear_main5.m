%% Shawn Albertson
% Published: 2/16/21
% Updated:   2/17/21

% Perform reconstruction using a single probe using FFT and calculate
% propagation error across multiple gauges

clear

addpath '/Users/shawnalbertson/Documents/Research/uri-waves/linear-reconstruction/functions'

load '../data/mat/1.10.22/A.mat'
% load '../data/mat/12.10.21/D.mat'

pram = struct;  % input parameters
stat = struct;  % calculated statistics

% reconstruction parameters
pram.fs = 32;          % sampling frequency
pram.Ta = 15;          % reconstruction assimilation time
pram.mu = .05;         % cutoff parameter
pram.mg = 6;           % measurement gauges
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



% Preprocess to get spatiotemporal points and resampled observations
[X, T, eta] = preprocess(pram, data, time, x);

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
    x_pred = [7,5,4,3,2,1];
    
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
title('Misfit at measured locations compared with evaluated prediction zone')

ylim([-5 pram.Ta+window - 5])
