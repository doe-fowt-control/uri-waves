% Rose Shayer
% 12/6/21
% Extracting Significant Wave Height from Irregular Wave Data

clc; clear; close all

%% Load data
load 'data.mat'
load 'time.mat'

% "Significant wave heihgt is defined as the average of the first (highest)
% N/3 waves" -D&D page 188

N=6; % number of wave gauges, could improve by defining N value based on data set size

for i = 1:1:N-1
    WG = data(:,i);             % Seperates the data from each wave gauge
    [height] = zeroup(WG,time); % determines each indivisual wave height w/ zeroup function
    Amp = sort(height);         % Sorts wave height values in descending order
    L = length(Amp);            % Calculates # of wave heights
    Third = Amp((2*L/3):L);     % Seperates the top 1/3 of the wave height values
    H_s(i) = mean(Third)        % Takes the average of the top 1/3 wave heights
    i = i+1;
end
 


%% zeroup function added below incase it is not already saved in the same folder

function [height, amp_c, amp_t, period, nw ,it] = zeroup(f,t)
%
% Version 1.01
%
%  zeroup.m: computing zero-up crossing wave height from data
%
%  Input - f: single column data
%          t: time series
%
%  Output - height: time series of wave height
%           amp_c : time series of crest wave amplitude
%           amp_t : time series of trough wave amplitude
%           period: time series of wave period
%           nw    : number of data
%
%  By Nobuhito Mori
%  Update 2007/07/30 put NaN if number of waves is zero 
%  Update 2001/04/10
%

%
% --- test
%

itest = 0;
if itest == 9
n  = 1000
dt = 0.1
T  = n*dt
Tp = T/10
t = 0:dt:(n-1)*dt;
f = cos(2*pi/Tp*t);
end

%
% --- main computation
%

n = length( f );

nw = 0;
iflag = 0;
fmax = 0;
fmin = 0;
it=0;

for i=1:n-1
   fmax = max( f(i+1), fmax );
   fmin = min( f(i+1), fmin );
   if ( f(i) <0 ) & ( f(i+1)>= 0 ) 
      t0 = t(i) - ( t(i+1) - t(i) )/( f(i+1) - f(i) )*f(i);
      if iflag == 0;
         iflag = 9;
         t_start = t0;
         fmax = 0;
         fmin = 0;
      else
         nw = nw + 1;
	 height(nw) = fmax - fmin;
         amp_c(nw) = fmax;
         amp_t(nw) = fmin;
         fmax = 0;
         fmin = 0;
	 t_end = t0;
         period(nw) = t_end - t_start;
         t_start = t_end;
         it(nw)=i;
      end
   end
end

if nw == 0
    height = NaN;
    period = NaN;
    amp_c  = NaN;
    amp_t  = NaN;
end
end
