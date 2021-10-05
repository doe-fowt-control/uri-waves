% Generation of a periodic wave (H,T) in depth h in OCE's wavetank, using
% flap wavemaker
% Needs function ldis.m in same folder

% Input (h,H,T,NW)
% Outpout V(t) (voltage time series to send the wavemaker for N waves
% h  : Water depth in tank (m)
% H  : wave height (m)
% T  : wave period (s)
% NW : nb.of waves in generated time series
% h0 : 1.92 m is measured elevation of flap jack from tank bottom
%
% 7/21 S. Grilli
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%cd 'C:\Users\Wavetank\Documents\2018 Capstone Sec. 2\Motion Control\Paddle Wavemaker'

% Fixed WM system data
%+++++++++++++++++++++

h0	= 1.92;	% total elevation of flap jack from tank bottom

% OLD Electro-mechanical stroke transfer function S0V(V0,TV) for sinusoidal
% motion: V(t) = 0.5*V0*(1 - cos(omv*t)) and S(t) = 0.5*S0V*(1 - cos(omv*t))
% with : omv = 2*pi/TV
% Gives maximum jack stroke S0V (m) as a function of maxmum oltage
% specified V0 (volt) and voltage period TV

S0V  = [        
 .023 .020 .017 .014 .011 .009 .006;
 .053 .046 .039 .031 .025 .020 .013;
 .083 .074 .062 .051 .041 .031 .021;
 .114 .102 .085 .071 .056 .041 .025;
 .142 .125 .105 .088 .071 .052 .034;
 .172 .149 .131 .106 .085 .063 .042;
 .200 .171 .149 .124 .101 .074 .049;
 .220 .190 .166 .140 .113 .083 .055];

V0V   = [0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00] ;   % Max voltage (V)   
TV    = [2.0 1.75 1.50 1.25 1.00 0.75 0.50];          % Voltage period (s)
[Tgrid,Vgrid] = meshgrid(TV',V0V);                    % Grid for interpolation

V0min   = min(V0V);
V0max   = max(V0V);
Tmin    = min(TV);       % Min WM period
Tmax    = max(TV);       % Max WM period

% Input data
%-----------

dt  = 0.05;     % Time step for copntrol time series

h 	= input('Enter the mean water depth in meters.			==> ');
H	= input('Enter the desired wave height in meters.		==> ');
T	= input('Enter the desired wave period in sec. (max=2)	==> ');
NW  = input('Enter number of waves to be generated	        ==> ');

% Wave parameters, wavemaker theory (DD 1991; Eq. (6.25)
%----------------------------------

L     = ldis(T,h);   % Wavelenght from linear dispersion relationship
%       ----
k     = 2*pi/L;      % Wavenumber
kh    = k*h;
omega = 2*pi/T;      % Angular frequency

S0 = (h0/h)*(H/4)*(kh/sinh(kh))*((sinh(2*kh)+2*kh)/(kh*sinh(kh)-cosh(kh)+1))

% Max flap wavemaker stroke 

S0min = interp2(Tgrid,Vgrid,S0V,V0min,T,'spline'); % Range of stroke for this T
S0max = interp2(Tgrid,Vgrid,S0V,V0max,T,'spline');

if (S0 > S0max) 
    H = input('Stroke too large for this T. Enter a smaller wave height ==> ');
end
if (S0 < S0min) 
    H = input('Stroke too small for this T. Enter a larger wave height ==> ');
end

% Max voltage interpolated for WM
%--------------------------------

S0T(:) = interp2(Tgrid,Vgrid,S0V,V0V(:),T,'spline'); % Range of stroke for this T
q      = polyfit(S0T,V0V,3);                         %  Curve fit V(S) for given T values
V0     = polyval(q,S0)                               %  Max voltage for Wavemaker control law

% Voltage timne series sent to wavemaker
%--------------------------------------

tmax = T*NW;
t    = 0:dt:tmax;
Nt   = length(t);
V    = 0.5*V0.*(1 - cos(omega*t));
Spad = 0.5*S0.*(1 - cos(omega*t));

figure(1)
plot(t,V,'-b','LineWidth',1.5)
grid on
hl = xlabel('t (s)');
set(hl,'FontSize',16','FontName','Times New Roman')
hl = ylabel('V (V)');
set(hl,'FontSize',16,'FontName','Times New Roman')
hl = title(['Voltage time series (H = ' num2str(H) ' m ; h = ' num2str(h) ' m ; T = ' num2str(T) ' s)']);
set(hl,'FontSize',16,'FontName','Times New Roman')
set(gca,'tickdir','out')
set(gcf,'Color','w')
set(gca,'FontSize',16);
set(gca,'XMinorTick','on','YMinorTick','on')
set(gca,'linewidth',1.5)

% Save figure
fnameb = ['wmlaw_verif.jpg'];
rez    = 300; %resolution (dpi) of final graphic
f      = gcf; %f is the handle of the figure you want to export
figpos = getpixelposition(f); 
resol  = get(0,'ScreenPixelsPerInch'); 
set(f,'Renderer','ZBuffer')
set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
print(f,fnameb,'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez
savefig(['wmlaw_verif.fig']);


