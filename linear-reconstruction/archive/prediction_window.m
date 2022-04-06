function [stat] = prediction_window(param, stat, x)

% Find prediction zone
locs = x;
locs(param.pg) = [];

x_b = min(locs);
x_j = max(locs);
x_p = x(param.pg);

c_g1 = 9.81 / (2 * stat.w_lo_pred);
c_g2 = 9.81 / (2 * stat.w_hi_pred);

stat.c_g1 = c_g1;
stat.c_g2 = c_g2;

stat.zone_lo = (x_p - x_j - c_g2 * param.Ta) / c_g2;
stat.zone_hi = (x_p - x_b) / c_g1;
