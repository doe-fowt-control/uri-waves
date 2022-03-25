% calibrate wave gauges using measurement from discrete heights, finding
% slope (cm/V) -> row 1 of s
% intercept, V when height = 0 -> row 2 of s
n = size(meas, 2);
cal = ones(2, n);
for i = 1:n
    s(:, i) = polyfit(heights, meas(:, i), 1);
end

hold on
plot(heights, meas)
x = linspace(-10, 10);
y = x'.*s(1, :) + s(2,:);
plot(x, y, 'k.')