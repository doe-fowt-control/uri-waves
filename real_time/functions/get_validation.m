function [pval, tval] = get_validation(pram, time, eta)
% find measured signal for validation timeframe

% validation measurements are the last bit of measurement data at the
% prediction gauge
pval = eta(end - pram.validation_size + 1 : end, pram.pg);

% extract validation time series directly from time history
tval = time(end - pram.validation_size + 1 : end);
% bring back to zero
tval = tval - min(tval);

