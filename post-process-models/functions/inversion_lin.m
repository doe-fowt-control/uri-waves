function stat = inversion_lin(pram, stat, X_, T_, eta_)
% stat.[w, k, a, b]

nf = pram.nf;
mg = pram.mg;

% frequency bandwidth for reconstruction
k_min = stat.k_min;
k_max = stat.k_max;


i1 = stat.i1;
i2 = stat.i2;

k = linspace(k_min, k_max, nf);
w = sqrt(k.*9.81);


X = X_(i1:i2, mg);
T = T_(i1:i2, mg);
eta = eta_(i1:i2, mg);

% plot(eta)
% legend("1", "2")
% title("decompose_ng line 25")


% n = length(eta);
% f = (0:n-1)*fs/n;
% f = f(1:round(n/2));
% 
% w = 2 * pi * f;
% 
% ll = 9.81/2/stat.c_g1;
% ll = ll*0.8;
% hh = 9.81/2/stat.c_g2;
% hh = hh*1.2;
% w = linspace(ll, hh, 20);
% 
% k = w.^2 / 9.81;

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


n = length(k);

a_n = weights(1:n);
b_n = weights(n+1:end);

% A = sqrt(a_n.^2 + b_n.^2)';
% phi = atan2(b_n, a_n)';


stat.a = a_n;
stat.b = b_n;
stat.w = w;
stat.k = k;
% stat.A = A;
% stat.phi = phi;