function [stat] = subset_1g(param, stat, t)
% indices of full series to be used in reconstruction

tr = param.tr;
Ta = param.Ta;

[~, i1] = min(abs(tr - Ta - t));
[~, i2] = min(abs(tr - t));

i2 = i2-1;

stat.i1 = i1;
stat.i2 = i2;