function [w] = freq_range(eta_obs, fs, c, n, method)
% fs - sampling frequency
% eta_obs - raw observations
% c - cutoff threshold for energy container
% n - number of frequencies to return
% method -
    % [any except 11] uses spacing calculated with curve fit to cumtrapz
    % for psd
    % 11 uses unvalidated method

% Evaluate spectral density using Welch method
% window = length(eta_obs) -> # of windows used in Welch method,
% maximimized because more windows seems to make the result more specific
% (for regular waves)
% noverlap = (default) -> 50% of window size
% nfft = (default) -> max(256 or the closest power of 2 to the window size)

% Calculate PSD
[pxx, f] = pwelch(eta_obs(:, 1), 1024, [],[], fs);

% Find where power is greater than some cutoff
thresh = pxx > max(pxx)*c;

% new frequency and power series within this range
f_ = f(thresh);
pxx_ = pxx(thresh);

% Isolate the minimum and maximum frequencies within this threshold
lo = min(f_);
hi = max(f_);

% Cumulative sum of area under PSD curve, normalized to be within 0-1
Q_ = cumtrapz(f_, pxx_) / trapz(f_, pxx_);

% Spline fit to cumsum (0-1) on horizontal, frequencies on vertical
pp = spline(Q_, f_);

% Evaluate spline fit at n linearly spaced points to get nonlinear spacing
% back. Multiply by 2*pi to get rad/s
w = 2*pi*ppval(pp, linspace(0,1,n));



if method == 11
% Create a biased array of frequencies
n = n/2;
    vector1 = nonLinspace(lo, thresh, n, nonLinVec);
    vector2 = nonLinspace(thresh, hi, n, nonLinVec);

vector = cat(1,vector1, nonLinVec); % concatenation of the 2 vectors

% convert to rad/s
w = 2*pi*vector;
end

end



% -------------------------------------------------------------------------
% nonLinspace(mn, mx, num, spacetype) returns a vector of non-linearly
% spaced elements based on spacing specified by spacetype.
%
% nonLinVec = nonLinspace(mn, mx, num, 'exp10') returns a vector of
% elements with smaller spacing at the beginning of the vector and greater
% spacing at the end of the vector based on the curve y = 10^x.
%
% nonLinVec = nonLinspace(mn, mx, num, 'cos') returns a vector of elements
% with smaller spacing at the beginning and end of the vector, and greater
% spacing in the middle based on the curve y = 1/2(1-cos(x)).
%
% nonLinVec = nonLinspace(mn, mx, num, 'log10') returns a vector of
% elements with greater spacing at the beginning of the vector and smaller
% spacing at the end of the vector.
%
%   Inputs:
%       mn        - The minimum value in the vector.
%       mx        - The maximum value in the vector.
%       num       - The number of elements in the vector.
%       spacetype - Specifies the type of spacing needed.
%
%   Outputs:
%       nonLinVec - A vector consisting of elements with spacing specified
%                   by spacetype.
%
%
% Created: 10/12/17 - Connor Ott
% Last Modified: 10/23/17 - Connor Ott
% -------------------------------------------------------------------------

function [nonLinVec] = nonLinspace( mn, mx, num, spacetype )

if strcmpi(spacetype, 'exp10')
    % exponentialliness is the upper bound of the original 10^x curve
    % before it is scaled to fit the limits requested by the user. Since
    % the concavity of 10^x changes in different parts of its domain,
    % different spacing is seen when using different bounds. After some
    % basic qualitative analysis, an exponentialliness of 20 seemed to be a
    % good fit for my purposes. Increasing this value will increase the
    % spacing towards the end of the vector and decrease it towards the
    % beginning.
    exponentialliness = 20;
    nonLinVec = (mx-mn)/exponentialliness * ...
                (10.^(linspace(0, log10(exponentialliness+1), num)) - 1)...
                + mn;

elseif strcmpi(spacetype, 'cos')
    nonLinVec = (mx - mn)*(0.5*(1-cos(linspace(0, pi, num)))) + mn;

elseif strcmpi(spacetype, 'log10')
    % As with exponentialliness, this defines the bounds on the log10(x)
    % curve. Increasing loginess will decreasing the spacing towards the
    % end of the vector and increase it towards the beginning.
    loginess = 1.5;
    nonLinVec = (mx - mn)/loginess* ...
                log10((linspace(0, 10^(loginess) - 1, num)+ 1)) + mn;

end

end




