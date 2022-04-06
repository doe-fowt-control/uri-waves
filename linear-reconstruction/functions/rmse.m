function [e] = rmse(estimated, measured, stat)

estimated_good = estimated(stat.pi1:stat.pi2);
measured_good = measured(stat.pi1:stat.pi2);

e = sqrt(mean((measured_good - estimated_good).^2)) / 0.03;