function stat = inversion_icwm(pram, stat)

mg = pram.mg;
nf = pram.nf;

if length(mg) == 1
    fprintf('WARNING \n Choppy not compatible with single gauge \n Continuing without choppy \n')
    return
end

X_ = stat.X;
T_ = stat.T;
eta_ = stat.eta;

k = stat.k;
w_lin = stat.w;
a = stat.a;
b = stat.b;

i1 = stat.i1;
i2 = stat.i2;

X = X_(i1:i2, mg);
T = T_(i1:i2, mg);
eta = eta_(i1:i2, mg);

L = numel(X); % number of spatiotemporal points, same as numel(T)

% Reshape elements for easier calculations
x_stack = reshape(X, [1, numel(X)]);
t_stack = reshape(T, [1, numel(T)]);

% Get corresponding wave height observations
eta_obs = reshape(eta, [numel(eta), 1]);

% ref. Desmars 2020
% vso = sum((a.^2 + b.^2) .* w' .* k');
% stat.Hs^2 * stat.k_p^(3/2) .* 9.81^(1/2);

[stokes_A, ~, stokes_w] = fft_decomp(pram, eta);
stokes_k = stokes_w .^2 ./ 9.81;
vso = sum(stokes_A.^2 .* stokes_w .* stokes_k);

% stokes_w_full = ones([1, nf]) .* stokes_w';
% [~, ids] = min(abs(stokes_w_full - w_lin), [], 1);
% 
% stokes_a = stokes_A(ids) .* cos(stokes_phi(ids));
% stokes_b = stokes_A(ids) .* sin(stokes_phi(ids));

w = w_lin + 1/2 .* vso .* k;

phi = k' * x_stack - w' * t_stack;

D = -a'.*(k.^(-3/2))*sin(phi) + b.*(k.^(-3/2))*cos(phi); % 1xL

psi = k' * (x_stack - D) - w' * t_stack;

% psi = k' * x_stack - w' * t_stack; % NxL
% 
% D = -a' .* (k.^(-3/2)) * sin(psi)+ b'.*(k.^(-3/2))*cos(psi); % 1xL
% 
% psi_disp = k' * (x_stack - D) - w' * t_stack; % NxL

ak = (a .* k') * ones(1, L);
bk = (b .* k') * ones(1, L);
% ak = (stokes_a' .* k') * ones(1, L);
% bk = (stokes_b' .* k') * ones(1, L);

awkt = a .* w' .* k' * t_stack;
bwkt = b .* w' .* k' * t_stack;
% awkt = stokes_a' .* w' .* k' * t_stack;
% bwkt = stokes_b' .* w' .* k' * t_stack;

k_asin_bcos = k' .* (a .* sin(psi) - b .* cos(psi));

k_acos_bsin_one = k'.* (a .* cos(phi) + b .* sin(phi)) + ones(size(phi));

P = cos(psi) - k_asin_bcos .* ( sin(phi) - (k_acos_bsin_one .* awkt) ) + ak;

Q = sin(psi) - k_asin_bcos .* (-cos(phi) - (k_acos_bsin_one .* bwkt) ) + bk;

% P = cos(psi) .* (ones(1, L) + bk .* sin(psi)) - ak .* sin(psi) .* sin(psi);
% Q = sin(psi) .* (ones(1, L) + ak .* cos(psi)) - bk .* cos(psi) .* cos(psi);

% Z = [P; Q] * [(cos(psi) + 1/2 * ak)', (sin(psi) + 1/2 * bk)'];
% 
% % preconditioner
% scaler = diag([k.^(-3/2), k.^(-3/2)]);
% 
% A = Z * scaler;


bloc11 = P*(cos(psi) + 1/2 * ak)';
bloc12 = P*(sin(psi) + 1/2 * bk)';
bloc21 = Q*(cos(psi) + 1/2 * ak)';
bloc22 = Q*(sin(psi) + 1/2 * bk)';

alpha=diag(k'.^(-3/2));

A = [bloc11*alpha, bloc12*alpha; bloc21*alpha,bloc22*alpha];


% construction of second matrix
B1 = P * eta_obs;
B2 = Q * eta_obs;

B = [B1;B2];

% resolve system

ampl = (A + pram.lam * eye(2*pram.nf)) \ B;
    
a = ampl(1:nf);
b = ampl((1+nf):(2*nf));

stat.a = a;
stat.b = b;

% Z = [cos(psi) + 1/2 * a_n * k_n, sin(psi) + 1/2 * b_n * k_n]; % 2N x L
% 
% P = 0; % N x L
% Q = 0; % N x L
% 
% Y = [P, Q];
% 
% X = Z * Y;
% 
% B = Y' * eta_obs;



