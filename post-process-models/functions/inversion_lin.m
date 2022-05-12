function stat = inversion_lin(pram, stat)

mg = pram.mg;

eta_ = stat.eta;

i1 = stat.i1;
i2 = stat.i2;

% % % % % % % % % % % %
% multiple gauge method
% % % % % % % % % % % %

if length(mg) ~= 1
    nf = pram.nf;
    X_ = stat.X;
    T_ = stat.T;
    
    % frequency bandwidth for reconstruction
    k_min = stat.k_min;
    k_max = stat.k_max;
    
    k = linspace(k_min, k_max, nf);
    w = sqrt(k.*9.81);
    
    X = X_(i1:i2, mg);
    T = T_(i1:i2, mg);
    eta = eta_(i1:i2, mg);
    
    % Reshape elements for easier calculations
    x_stack = reshape(X, [1, numel(X)]);
    t_stack = reshape(T, [1, numel(T)]);
    
    % Get corresponding wave height observations
    eta_obs = reshape(eta, [numel(eta), 1]);
    
    % % Calculate optimal weights using linear regression
    % w = inv(X'X)X'y
    
    psi = k' * x_stack - w' * t_stack;
    
    Z = [cos(psi)', sin(psi)'];
    
    % scale by k_n.^(-3/2)
    scaler = diag([k.^(-3/2), k.^(-3/2)]);
    
    weights = (Z'*Z + pram.lam*eye(2*pram.nf))*scaler \ (Z'*eta_obs);
    % weights = (Z'*Z)*scaler \ (Z'*eta_obs);
    
    a_n = weights(1:nf);
    b_n = weights(nf+1:end);
    
    stat.a = a_n;
    stat.b = b_n;
    stat.w = w;
    stat.k = k;

% % % % % % % % % % %
% single gauge method
% % % % % % % % % % %

elseif length(mg) == 1
    eta = eta_(i1:i2, mg);
    
    [A, phi, w] = fft_decomp(pram, eta);
    
    a = A .* cos(phi);
    b = A .* sin(phi);
    
    k = w.^2 / 9.81;
    
    stat.k = k;
    stat.w = w;
    stat.a = a;
    stat.b = b;
end