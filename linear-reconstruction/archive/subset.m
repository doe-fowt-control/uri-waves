function [stat, X_train, T_train, eta_train] = subset(param, stat, X, T, eta_obs)

mg = param.mg;      % measurement gauges
tr = param.tr;
Ta = param.Ta;

[~, i1] = min(abs(tr - Ta - T(:, 1)));
[~, i2] = min(abs(tr - T(:, 1)));

i2 = i2-1;

X_train = X(i1:i2, mg);
T_train = T(i1:i2, mg);
eta_train = eta_obs(i1:i2, mg);

stat.i1 = i1;
stat.i2 = i2;