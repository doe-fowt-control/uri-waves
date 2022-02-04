function s = reconstruct(a_n, b_n, X, x_stack, t_stack, k_n, w_n)
% a_n, b_n weights for cos() sin() respectively
% axis (string) whether to visualize x or t
% which entry of x or t to visualize

s_a = a_n .* cos(k_n'*x_stack - w_n'* t_stack);
s_b = b_n .* sin(k_n'*x_stack - w_n'* t_stack);

s_long = k_n.^(-3/2) * (s_a + s_b);

s = reshape(s_long, size(X));

% if axis == 'x'
%     slice = s(index, :);
% end
% 
% if axis == 't'
%      slice = s(:, index);
% end