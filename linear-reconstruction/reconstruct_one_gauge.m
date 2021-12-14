function slice = reconstruct_one_gauge(x, t, k, w, a, b, index)
% x - spatial array
% t - temporal array
% index - index of opposite axis which to slice on

x_test = x(index);
s_a = a .* cos(k' * ones(1, length(t)) .* x_test - w' * t');
s_b = b .* sin(k' * ones(1, length(t)) .* x_test - w' * t');

slice = k.^(-3/2) * (s_a + s_b);



