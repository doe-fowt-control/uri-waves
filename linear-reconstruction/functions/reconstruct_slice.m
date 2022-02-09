function [slice, t] = reconstruct_slice(param, X_, T_, a, b, w, k)
% x - spatial array
% t - temporal array
% index - index of opposite axis which to slice on

pg = param.pg;
tr = param.tr;
fs = param.fs;
np = param.np;

x_test = X_(1, pg);

t = T_(tr*fs:(tr+np)*fs, 1);

s_a = a .* cos(k' * ones(1, length(t)) .* x_test - w' * t');
s_b = b .* sin(k' * ones(1, length(t)) .* x_test - w' * t');

slice = k.^(-3/2) * (s_a + s_b);



