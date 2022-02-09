function [e] = rmse(estimated, measured, stat)

estimated_good = estimated(stat.tp1:stat.tp2);
measured_good = measured(stat.tp1:stat.tp2);

e = sqrt(mean((measured_good - estimated_good).^2)) / 0.03;