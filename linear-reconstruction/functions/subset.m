function [X_train, T_train, eta_train] = subset(param, X, T, eta_obs)

mg = param.mg;      % measurement gauges
pt = param.pt;
nt = param.nt;

X_train = X(pt-nt:pt, mg);
T_train = T(pt-nt:pt, mg);
eta_train = eta_obs(pt-nt:pt, mg);