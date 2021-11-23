function [a_n, b_n] = linear_weights_sampled(signal, X, T, nx, nt, k_n)
% signal - wave height data with x values as columns and t values as rows
% X - the full series of x values in matrix form (meshgrid with t)
% T - the full series of t values in matrix form (meshgrid with x)
    % t in rows, x in columns
% nx - number of x values to use in reconstruction
% nt - number of t values to use in reconstruction
% k - series of wavenumbers for reconstruction

g = 9.81; % m/s2

% Count total number of time and space instances. X and T are same shape
xs = size(X, 2); % x in columns
ts = size(X, 1); % t in rows

% Grab specified subset of each space, time matrix
x_sample = X(1:nt, 1:xs/nx:end);
t_sample = T(1:nt, 1:xs/nx:end);

% Reshape elements for easier calculations
x_stack = reshape(x_sample, [1, numel(x_sample)]);
t_stack = reshape(t_sample, [1, numel(t_sample)]);

% Get corresponding wave height observations
eta_obs_sample = signal(1:nt, 1:xs/nx:end);
eta_obs = reshape(eta_obs_sample, [numel(eta_obs_sample), 1]);

% Create frequencies based on deep water relation to wave number
w_n = sqrt(g.*k_n);

% % Calculate optimal weights using linear regression
% w = inv(X'X)X'y

psi = k_n' * x_stack - w_n' * t_stack;

X = [cos(psi)', sin(psi)'];

% scale by k_n.^(-3/2)
scaler = diag([k_n.^(-3/2), k_n.^(-3/2)]);

weights = (X'*X)*scaler\(X'*eta_obs);

n = length(k_n);

a_n = weights(1:n);
b_n = weights(n+1:end);


% % Another way to write the linear regression algorithm

% bloc11 = cos(psi)*cos(psi)';
% bloc12 = cos(psi)*sin(psi)';
% bloc21 = sin(psi)*cos(psi)';
% bloc22 = sin(psi)*sin(psi)';
% 
% % Apply preconditioning before inversion
%  
% alpha  = diag(k_n'.^(-3/2));
% 
% A = [bloc11*alpha, bloc12*alpha; bloc21*alpha,bloc22*alpha];
% 
% B1 = cos(psi)*eta_obs;
% B2 = sin(psi)*eta_obs;
% 
% B  = [B1;B2];
% 
% weights = A\B;

