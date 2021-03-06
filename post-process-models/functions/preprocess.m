function stat = preprocess(pram, stat, data, time, x)
% Trim data before waves fully develop and after waves stop
% Center on mean
% Resample at desired frequency
% Make spatiotemporal instances using meshgrid

fs_new = pram.fs;

% find original sampling frequency (round to integer)
fs_old = round(1/((time(end)-time(1))/numel(time)), 0);

% bring time back to start at zero
time = time - time(1);

try
    data = data .* pram.slope;
    data = data - pram.intercept;
catch
end

% center on mean
data = data - mean(data);

% resample time and observations
eta = data(1: fs_old / fs_new :end, :);
t = time(1: fs_old / fs_new :end);

stat.x = x;
stat.t = t;
stat.eta = eta;

% make spatiotemporal samples if multiple wave gauges
if length(pram.mg) ~= 1
    % spatiotemporal samples
    [X, T] = meshgrid(x, t);
    stat.X = X;
    stat.T = T;
end

