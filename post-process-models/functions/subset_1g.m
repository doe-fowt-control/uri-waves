function [stat] = subset_1g(pram, stat)
% indices of full series to be used in reconstruction

tr = pram.tr;
Ta = pram.Ta;

t = stat.t;

[~, i1] = min(abs(tr - Ta - t));
[~, i2] = min(abs(tr - t));

i2 = i2-1;

stat.i1 = i1;
stat.i2 = i2;