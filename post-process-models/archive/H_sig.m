
function [H_sig] = H_sig(data,time,N)

% Computes the significant wave height for irregular wave data 
% N is number of wave gauges used

    for i = 1:1:N-1
        WG = data(:,i);             % Seperates the data from each wave gauge
        [height] = zeroup(WG,time); % determines each indivisual wave height w/ zeroup function
        Amp = sort(height);         % Sorts wave height values in descending order
        L = length(Amp);            % Calculates # of wave heights
        Third = Amp((2*L/3):L);     % Seperates the top 1/3 of the wave height values
        H_s(i) = mean(Third)        % Takes the average of the top 1/3 wave heights
        i = i+1;
    end
end