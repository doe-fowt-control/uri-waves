function [stat] = subset(pram, stat)
% indices of full series to be used in reconstruction
% indices of full series to be used as spectral data

t = stat.t;

tr = pram.tr;
Ta = pram.Ta;
ts = pram.ts;

% lower index for reconstruction
[~, i1] = min(abs(tr - Ta - t));
stat.i1 = i1;

% lower index for spectral
[~, si1] = min(abs(tr - ts - t));
stat.si1 = si1;

% upper index for reconstruction and spectral are the same
[~, i2] = min(abs(tr - t));
i2 = i2-1;

stat.i2 = i2;
stat.si2 = i2;




