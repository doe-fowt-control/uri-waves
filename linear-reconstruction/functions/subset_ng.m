function [stat] = subset2(param, stat, T)
% indices of full series to be used in reconstruction

tr = param.tr;
Ta = param.Ta;

[~, i1] = min(abs(tr - Ta - T(:, 1)));
[~, i2] = min(abs(tr - T(:, 1)));

i2 = i2-1;

stat.i1 = i1;
stat.i2 = i2;