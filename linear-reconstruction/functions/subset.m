function [param, X_train, T_train, eta_train] = subset(param, X, T, eta_obs)

mg = param.mg;      % measurement gauges

[v, i1] = min(abs(param.tr - param.Ta - T(:, 1)));
[v, i2] = min(abs(param.tr - T(:, 1)));

i2 = i2-1;

X_train = X(i1:i2, mg);
T_train = T(i1:i2, mg);
eta_train = eta_obs(i1:i2, mg);

param.i1 = i1;
param.i2 = i2;


% % Removed 2/11/22
% pt = param.pt;
% nt = param.nt;
% 
% X_train = X(pt-nt:pt-1, mg);
% T_train = T(pt-nt:pt-1, mg);
% eta_train = eta_obs(pt-nt:pt-1, mg);