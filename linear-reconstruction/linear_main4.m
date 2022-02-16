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
param.tr = 60;      % reconstruction time
param.Ta = 20;          % reconstruction assimilation time
param.mu = .05;         % cutoff parameter
param.mg = 6;           % measurement gauges
% param.pg = 1;           % gauge to predict at
param.window = 25;       % number of seconds outside of prediction to use for visualization

mg = param.mg;
% pg = param.pg;
tr = param.tr;            % initial time (s)
Ta = param.Ta;             % assimilation time (s)
fs = param.fs;
window = param.window;

stat = struct;

x_lab = [2,3,4,5,6];
x_pred = [7,5,4,3,2,1];

% e_list = ones(1121,5);

for xi = 1:1:length(x_pred)
    param.pg = x_pred(xi);
    pg = param.pg;

    % Preprocess to get spatiotemporal points and resampled observations
    [X_, T_, eta_] = preprocess(param, data, time, x);
    
    % Try removing entries from full time array
    T_(1:100, :) = [];
    
    % Select subset of data for remaining processing
    [stat, X, T, eta] = subset(param, stat, X_, T_, eta_);
    
    % Find frequency, wavenumber, amplitude, phase
    [stat, w, k, A, phi] = freq_fft(param, stat, eta);
    
    % % Check that reconstruction worked (create plots)
    % check_reconstruction(param, stat, T_, eta_, w, A, phi)
    
    % Propagate to new space / time region
    [r, t, stat] = reconstruct_slice_fft(param, stat, X_, T_, w, k, A, phi);
    
    % Unpack time values for prediction window
    t_min = stat.t_min;
    t_max = stat.t_max;
    
    % Get corresponding measured data
    p = eta_(stat.i1 - window * fs:stat.i2 + window * fs +1, pg);

    e = abs((r-p).^2) / (2 * var(eta));
    
    e_list(:, xi) = e;

%     figure
%     subplot(2,1,1)
%     hold on
%     plot(t, r, 'k--', 'linewidth', 2)
%     plot(t, p, 'b')
%     xline(t_min, 'g-.')
%     xline(t_max, 'r-.')
%     legend('prediction', 'measurement', 'prediction zone')
%     xlabel('time (s)')
%     ylabel('amplitude (m)')
%     title(['Wave forecast and measurement at gauge ' num2str(x_lab(xi))])
%     ylim([-0.03 0.03])
% 
%     subplot(2,1,2)
%     plot(t, e, 'r')
%     xline(t_min, 'g-.')
%     xline(t_max, 'r-.')
%     legend('error', 'prediction zone boundary')
%     xlabel('time (s)')
%     ylabel('error')
%     title(['Error assessment for simple wave forecast at gauge ' num2str(x_lab(xi))])
%     ylim([0 10])


end

figure
hold on
d = 1;
xd = linspace(min(x(x_pred)) - d, max(x(x_pred)) + d, 300);
i_list = ones(1, length(x_pred));
for xi = 1:1:length(x_pred)
    i_list(xi) = find(abs(x(x_pred(xi)) - xd) == min(abs(x(x_pred(xi)) - xd)));
end

C = zeros(length(t), length(xd));
C(:, i_list) = e_list;
for id = 1:1:3
    C(:, i_list - id) = e_list;
    C(:, i_list + id) = e_list;
end

imagesc(xd, t, C, [0 5])
set(gca,'YDir','normal') 
colorbar
colormap(flipud(gray))
% colormap(cool)
% myColorMap = gray;
% myColorMap(1,:) = 1;
% colormap(myColorMap);

a = 0;
b = max(x(x_pred)) + a;
c = min(x(x_pred)) * 0;
plot([c b], [1/stat.c_g2 * c 1/stat.c_g2 * b], 'r-')
plot([c b], [Ta+1/stat.c_g1 * c Ta+ 1/stat.c_g1 * b], 'r-')
xline(x(x_pred), 'k:')

xlabel('x')
ylabel('t')


% figure % splits onto multple graphs
% for m = 1:1:length(x_pred)
%     subplot(length(x_pred), 1, m)
%     plot(t, e_list(:, xi))
% end

% figure % Connects multiple lines
% T = [t t t t t t];
% X = ones(length(t), length(x_pred)) .* x(x_pred);
% X = reshape(X, [1 length(T)]);
% E = reshape(e_list, [1, length(T)]);
% hold on
% plot3(X, T, E, 'k-')
% 
% a = 3;
% b = max(x(x_pred)) + a;
% zh = 50;
% 
% x1 = [0 b;
%       0 b];
% y1 = [0 1/stat.c_g2 * b;
%       0 1/stat.c_g2 * b];
% z1 = [0 0;
%       zh zh];
% surf(x1, y1, z1)
% 
% x2 = [0 b;
%       0 b];
% y2 = [Ta Ta+ 1/stat.c_g1 * b;
%       Ta Ta+ 1/stat.c_g1 * b];
% z2 = [0 0;
%       zh zh];
% surf(x2, y2, z2)


% figure % Slow
% hold on
% for m = 1:1:length(x_pred)
%     plot3(x(x_pred(m)) * ones(length(t)), t, e_list(:,m))
% %     plot3(x(x_pred(1)) * ones(length(t)), t, e_list(:,1))
% end
