function [a_n, b_n] = linear_weights(X_train, T_train, eta_train, w, k)
% param - struct with simulation parameters
% X_train - the target series of x values in matrix form (meshgrid with t)
% T_train - the target series of t values in matrix form (meshgrid with x)
    % t in rows, x in columns
% eta_train - target wave height data with x values as columns and t values as rows
% w - series of frequencies for reconstruction
% k - series of wavenumbers for reconstruction


% Reshape elements for easier calculations
x_stack = reshape(X_train, [1, numel(X_train)]);
t_stack = reshape(T_train, [1, numel(T_train)]);

% Get corresponding wave height observations
eta_obs = reshape(eta_train, [numel(eta_train), 1]);

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

