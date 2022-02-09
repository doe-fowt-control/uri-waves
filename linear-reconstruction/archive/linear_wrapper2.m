function [a, b, w, k, stat] = linear_wrapper2(param, X, T, eta)

% Calculate spectrum using specified spectral assimilation time
[w, k, stat] = freq_range(param, eta);

% Find linear weights of decomposition
[a, b] = linear_weights2(X, T, eta, w, k);






