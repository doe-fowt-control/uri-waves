function stat = inversion_cwm(pram, stat)

mg = pram.mg;

if length(mg) == 1
    fprintf('WARNING \n Choppy not compatible with single gauge \n Continuing without choppy \n')
    return
end

X_ = stat.X;
T_ = stat.T;
eta_ = stat.eta;


nf = pram.nf;

k = stat.k;
w = stat.w;
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

psi = k' * x_stack - w' * t_stack; % NxL

D = -a' .* (k.^(-3/2)) * sin(psi)+ b'.*(k.^(-3/2))*cos(psi); % 1xL

psi_disp = k' * (x_stack - D) - w' * t_stack; % NxL

ak = (a' .* k.^(-1/2))' * ones(1, L);
bk = (b' .* k.^(-1/2))' * ones(1, L);

P = cos(psi_disp) .* (ones(1, L) + bk .* sin(psi)) - ak .* sin(psi) .* sin(psi_disp);
Q = sin(psi_disp) .* (ones(1, L) + ak .* cos(psi)) - bk .* cos(psi) .* cos(psi_disp);

Z = [P; Q] * [cos(psi_disp)', sin(psi_disp)'];

% bloc11 = P*cos(psi_disp)';
% bloc12 = P*sin(psi_disp)';
% bloc21 = Q*cos(psi_disp)';
% bloc22 = Q*sin(psi_disp)';

% preconditioner
scaler = diag([k.^(-3/2), k.^(-3/2)]);

A = Z * scaler;


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



