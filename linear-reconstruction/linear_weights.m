function [a_n, b_n] = linear_weights(signal, X, T, pt, nt, w, k)
% signal - wave height data with x values as columns and t values as rows
% X - the full series of x values in matrix form (meshgrid with t)
% T - the full series of t values in matrix form (meshgrid with x)
    % t in rows, x in columns
% pt - prediction time (index of)
% nt - number of t values to use in reconstruction
% w - series of frequencies for reconstruction
% k - series of wavenumbers for reconstruction

g = 9.81; % m/s2

% % Count total number of time and space instances. X and T are same shape
% xs = size(X, 2); % x in columns
% ts = size(X, 1); % t in rows

% Grab specified subset of each space, time matrix
x_sample = X(pt-nt:pt, :);
t_sample = T(pt-nt:pt, :);

% Reshape elements for easier calculations
x_stack = reshape(x_sample, [1, numel(x_sample)]);
t_stack = reshape(t_sample, [1, numel(t_sample)]);

% Get corresponding wave height observations
eta_obs_sample = signal(pt-nt:pt, :);
eta_obs = reshape(eta_obs_sample, [numel(eta_obs_sample), 1]);

% % Calculate optimal weights using linear regression
% w = inv(X'X)X'y

psi = k' * x_stack - w' * t_stack;

Z = [cos(psi)', sin(psi)'];

% scale by k_n.^(-3/2)
scaler = diag([k.^(-3/2), k.^(-3/2)]);

weights = (Z'*Z)*scaler \ (Z'*eta_obs);

n = length(k);

a_n = weights(1:n);
b_n = weights(n+1:end);

