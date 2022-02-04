% Generation of a irregular waves (Hs,Tp) in depth h in OCE's wavetank, using
% flap wavemaker
% [OMEGMIN,OMEGMAX] : constraint on maximum/min freq. from wavemaker
%
% Waves energy is represented by a JS spectrum of peakedness JSGAM,
% truncated at EPSSP fraction of its peak
% Needs function ldis.m, zeroup.m  and spectre13 in same folder (returns:
% [AMPN,PSIN,OMEGAN] for MOMSP wave components in spectrum)
%
% Input (h,Hs,Tp,NW); ehre NW is nb.of peak waves in time series
% Outpout V(t) (voltage time series to send the wavemaker for N waves
%
% 9/10/18 S. Grilli
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


cd 'C:\Users\Wavetank\Documents\2018 Capstone Sec. 2\Motion Control\Paddle Wavemaker'

Hs = .055;
Tp = 0;
NW = 100;
h = 1.58; 


% Parameters
%-----------

global  FETCH U10 AMPS JSGAM OMEGAP EPSSP GE            % These parameters are provided
global  SWAVE AMP0 OMSMIN OMSMAX OMEGMAX OMEGMIN        % These parameters are calculated

h0	= 1.933;	% total elevation of flap jack from tank bottom
dt  = 0.005;     % Time step for copntrol time series

S0V  = [        % Electro-mechanical stroke transfer function S0V(V0,TV)
 .023 .020 .017 .014 .011 .009 .006;
 .053 .046 .039 .031 .025 .020 .013;
 .083 .074 .062 .051 .041 .031 .021;
 .114 .102 .085 .071 .056 .041 .025;
 .142 .125 .105 .088 .071 .052 .034;
 .172 .149 .131 .106 .085 .063 .042;
 .200 .171 .149 .124 .101 .074 .049;
 .220 .190 .166 .140 .113 .083 .055];

V0V   = [0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00] ; % Max voltage (V)   % got rid of factor of 1.5
TV    = [2.0 1.75 1.50 1.25 1.00 0.75 0.50];            % Period (s)
[Tgrid,Vgrid] = meshgrid(TV',V0V);                    % Grid for interpolation

V0min   = 0.25;
V0max   = 2.00;
Tmin    = 0.5;       % Min WM period
Tmax    = 2.0;       % Max WM period
OMEGMAX = 2*pi/Tmin;
OMEGMIN = 2*pi/Tmax;

FETCH = -1.;          % Fixed parameters for spectre13
U10   = 0.;
JSGAM = 3.;          % JS peakedness
EPSSP = 0.01;       % JS spectrum truncation
NOMSP = 100;         % Number of JS wave components
GE    = 9.81;

% Input data
%-----------

%h 	= input('Enter the mean water depth in meters.	     ==> ');
%Hs	= input('Enter the significant wave height (m)       ==> ');
%Tp	= input('Enter the peak spectral period (s) (max=2)	 ==> ');
%NW  = input('Enter number of peak waves to be generated	 ==> ');

AMPS   = Hs/2;
OMEGAP = 2*pi/Tp;

% Generates JS spectrum and wave harmonics
%-----------------------------------------

[AMPN,PSIN,OMEGAN] = spectre13(NOMSP);
Tp = 2*pi/OMEGAP;
%                    ---------
Hs0 = 2*AMP0;
fmin = OMSMIN/(2*pi);
fmax = OMSMAX/(2*pi);
TN   = 2*pi./OMEGAN;

figure(1)
plot(OMEGAN/(2*pi),SWAVE); % spectral amplitude plot
title(['Ocean wave spectrum' ' H_{s0}=' num2str(Hs0) ' m, T_p=' num2str(Tp) ' s'],...
           'fontsize',16);    
xlabel('f (Hz)','fontsize',16);
ylabel('S (m^2. s)','fontsize',16);
grid on;
NOM = NOMSP;

% Wave parameters, wavemaker theory
%----------------------------------

LN    = ldis(TN,h);  % Wavelenght from linear dispersion relationship
%       ----
kN    = 2*pi./LN;      % Wavenumber
kNh   = kN*h;

% Max flap wavemaker stroke corrected for elevation (DD 1991; Eq. (6.25))

S0N = (h0/h)*(AMPN/2).*(kNh./sinh(kNh)).*((sinh(2*kNh)+ 2*kNh)./(kNh.*sinh(kNh)-cosh(kNh)+1));

% Stroke time series for WM 
%---------------------------

tmax = Tp*NW;
t    = 0:dt:tmax;
Nt   = length(t);

% Wave time series targeted in tank

for it = 1:Nt
    eta(it) = 0.5*sum(AMPN(:).*(cos(OMEGAN(:)*t(it) + PSIN(:))));
end

figure(2)
plot(t,eta,'-b','LineWidth',1.5)
grid on
xlabel('t (s)','Fontsize',20);
ylabel('\eta (m)','Fontsize',20);
title(['Wave time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
set(gca,'FontSize',20);

% Theoretical stroke time series

for it = 1:Nt
    S(it) = 0.5*sum(S0N(:).*(1 - cos(OMEGAN(:)*t(it) + PSIN(:))));
end

Smean = mean(S);  % Demean stroke for ZUC
Scorr = S - Smean;

figure(3)
plot(t,Scorr,'-b','LineWidth',1.5)
grid on
xlabel('t (s)','Fontsize',20);
ylabel('S (m)','Fontsize',20);
title(['Stroke time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
set(gca,'FontSize',20);

% ZUC analysis opf stroke time series
%------------------------------------

jzuc    = 0;
Nst     = 0;
Scmax   = 0;
Scmin   = 0;
tstart  = 0;

for it = 1:Nt-1
    Scmax = max(Scorr(it),Scmax);
    Scmin = min(Scorr(it),Scmin);
    
    if (Scorr(it) < 0) & (Scorr(it+1) >= 0)  % ZUC
        jzuc       = jzuc + 1; 
        izuc(jzuc) = it;
        tend(jzuc) = t(it) + (dt/(Scorr(it+1)-Scorr(it)))*Scorr(it+1);
        Sper(jzuc) = tend(jzuc) - tstart;
        tstart     = tend(jzuc);
        Sint(jzuc) = Scmax - Scmin;
        Nst         = Nst + 1;
        Scmax      = 0;
        Scmin      = 0;
    end
end

% Enforces lower and upper bound on stroke based on wavemaker stroke function

for n=2:Nst
    Sfin(n-1) = Sint(n);  % Shift to the first ZUC
    
    S0min  = interp1(TV,S0V(1,:),Sper(n),'spline'); % Min stroke for this T, Vmin
    S0max  = interp1(TV,S0V(8,:),Sper(n),'spline'); % Max stroke for this T, Vmax

    if (Sint(n) > S0max) 
        Sfin(n-1) = S0max;
    end
    if (Sint(n) < S0min) 
        Sfin(n-1) = S0min;
    end
end

STfin  = Sper(2:Nst);
tstr   = t(izuc) - t(izuc(1));              % beginning and end of each stroke
tcor   = t(izuc(1):izuc(Nst))- t(izuc(1));  % new time series
Scorr0 = Scorr(izuc(1):izuc(Nst));          % new stroke time series
Nst    = Nst-1;                             % Nb. of strokes
Ntc    = length(tcor);

figure(31)
plot(tcor,Scorr0,'-b','LineWidth',1.5)
grid on
xlabel('t (s)','Fontsize',20);
ylabel('S (m)','Fontsize',20);
title(['Stroke time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
set(gca,'FontSize',20);

% Max voltage for each (trough to crest) stroke in ZUC analysis

for n=1:Nst
    S0T(:) = interp2(Tgrid,Vgrid,S0V,V0V(:),STfin(n),'spline'); % Range of stroke for this JS spectrum
    q      = polyfit(S0T,V0V,3);   %  Curve fit V(S) for given T values
    V0(n)  = polyval(q,Sfin(n));   %  Max voltage for Wavemaker control law
end

V0all = [0 V0];
V0fit = interp1(tstr,V0all,tcor);   %  Curve fit V0(strokes) 

figure(4)
plot(tstr,V0all,'-b',tcor,V0fit,'-r','LineWidth',1.5)
grid on
xlabel('t (s)','Fontsize',20);
ylabel('V (V)','Fontsize',20);
title(['Max voltage time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
set(gca,'FontSize',20);

% Voltage timne series with random phase, to be sent to wavemaker
%----------------------------------------------------------------

Sfac = Sint(2);
iac  = 1;
it   = 1;

while (it <= Ntc) & (iac <= Nst)    
    if tcor(it) > tstr(iac+1)
        iac = iac + 1;
        Sfac = Sint(iac+1);
    end
    Scorrc(it) = Scorr0(it)/Sfac;
    Vcal(it)   = V0fit(it)*Scorrc(it);
    it = it + 1;
end

%figure(5)
%plot(tcor,Vcal,'-b','LineWidth',1.5)
%grid on
%xlabel('t (s)','Fontsize',20);
%ylabel('V (V)','Fontsize',20);
%title(['Voltage time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
%set(gca,'FontSize',20);

%figure(6)
%plot(tcor,Scorrc,'-b','LineWidth',1.5)
%grid on
%xlabel('t (s)','Fontsize',20);
%ylabel('Sc (m)','Fontsize',20);
%title(['Stroke time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
%set(gca,'FontSize',20);

