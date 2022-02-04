function slice = reconstruct_slice(x, t, k_n, w_n, a_n, b_n, axis, index)
% x - spatial array
% t - temporal array
% axis - choose which axis to capture
% index - index of opposite axis which to slice on

if axis == 'x'
    t_test = t(index);

    s_a = a_n .* cos(k_n'*x - w_n'* ones(1,length(x)) .* t_test);
    s_b = b_n .* sin(k_n'*x - w_n'* ones(1,length(x)) .* t_test);
    
    slice = k_n.^(-3/2) * (s_a + s_b);
end


if axis == 't'
    x_test = x(index);
    s_a = a_n .* cos(k_n' * ones(1, length(t)) .* x_test - w_n' * t');
    s_b = b_n .* sin(k_n' * ones(1, length(t)) .* x_test - w_n' * t');
    
    slice = k_n.^(-3/2) * (s_a + s_b);
end



