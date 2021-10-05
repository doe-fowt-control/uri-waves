% Generation of a irregular waves (Hs,Tp) in depth h in OCE's wavetank, using
% flap wavemaker
% [OMEGMIN,OMEGMAX] : constraint on maximum/min freq. from wavemaker
%
% Waves energy is represented by a JS spectrum of peakedness JSGAM,
% truncated at EPSSP fraction of its peak
% Needs function ldis.m, zeroup.m  and spectre13.m in same folder (returns:
% [AMPN,PSIN,OMEGAN] for MOMSP wave components in spectrum)
%
% Input (h,Hs,Tp,NW) in MKS
% Outpout V(t) (voltage time series to send the wavemaker for N waves
% h  : Water depth in tank (m)
% Hs : significant wave height (m)
% Tp : Spectral peak period (s)
% NW : nb.of peak waves in generated time series
% h0 : 1.92 m is measured elevation of flap jack from tank bottom
%
% Method
%-------
% 1. Compute target JS spectrum : JS(Hs,Tp,gamma)
% 2. Extract random surface elevation time series eta(t) form spectrum
% 3. ZUC analysis of eta(t) => individual (H_n,T_n), n=1,...,NW
% 4. Apply transfer function for periodic waves f_n = S_n/H_n with upper
% and lower bound verification on S_n(T_n) truncating surface elevation
% 5. Compute V_n(S_n,T_n) based on elctro-mechanical wavemaker law
% 6. Interpolate S_n, V_n and H_n as a continuous function over t
% 7. Compute shape function Sh(t) = eta(t)/H_n(t)
% 8. Compute final time series of stroke : S(t) = S_n(t) * Sh(t)
%    Compute final time series of voltage: V(t) = V_n(t) * Sh(t)
% Note: as this is proportional to eta(t) the time series oscillate from
% negative to positive values so at t=0, the wavemaker must be moved forward 
% of at least the minimum stroke in the time series.
%
% 7/21 S. Grilli
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all;

global  FETCH U10 AMPS JSGAM OMEGAP EPSSP GE            % These parameters are provided
global  SWAVE AMP0 OMSMIN OMSMAX OMEGMAX OMEGMIN        % These parameters are calculated

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

% Spectral fixed data;

OMEGMAX = 2*pi/Tmin;
OMEGMIN = 2*pi/Tmax;

FETCH = 0.;          % Fixed parameters for spectre13 for JONSWAP spectrum
U10   = 0.;

EPSSP = 0.005;        % JS spectrum truncation
NOMSP = 1000;        % Number of JS wave components
GE    = 9.81;

% User supplied input data
%+++++++++++++++++++++++++

fra    = 20;    % Frequency for generating control time series
dt     = 1/fra;

h 	   = input('Enter the mean water depth in meters.			==> ');
Hs     = input('Enter the desired significant wave height in meters.		==> ');
Tp	   = input('Enter the desired peak period in sec. (max=2)	==> ');
NW     = input('Enter number of waves to be generated	        ==> ');
JSGAM  = input('Enter JS spectrum peakedness gamma	        ==> ');   % JS peakedness
AMPS   = Hs/2;  
OMEGAP = 2*pi/Tp;

pltall = 1;     % Plot figures if 1; no plot if 0

%directo = '/Users/sgrilli/Documents/STEPHAN/CLASSES/OCE495-496/SENIOR-PROJECTS-19/Capstone_OCE496/'; % General directory
%dirtest = 'Test7_run/'; % Test directory
directo = '';
dirtest = '';
outdir  = [directo dirtest];  % Directory to output results
outfile = 'Wavemaker_Data.txt';

% Generates JS spectrum, wave harmonics, target surface time series
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Spectral analysis => JS(Hs,Tp,Gamma)

[AMPN,PSIN,OMEGAN] = spectre13(NOMSP);
%                    ---------
Hs0  = 2*AMP0 % Actual Hs for generated JS spectrum
fmin = OMSMIN/(2*pi);
fmax = OMSMAX/(2*pi);
TN   = 2*pi./OMEGAN;

% Target surface time series 

tmax = Tp*NW;
t    = 0:dt:tmax;
Nt   = length(t);

% Wave time series targeted in tank

for it = 1:Nt
    eta(it) = sum(AMPN(:).*(cos(OMEGAN(:)*t(it) + PSIN(:))));
end

% ZUC analysis of eta time series
%++++++++++++++++++++++++++++++++

jzuc    = 0;
Nst     = 0;
etamax  = 0;
etamin  = 0;
tstart  = 0;

for it = 1:Nt-1
    etamax = max(eta(it),etamax);
    etamin = min(eta(it),etamin);
    
    if (eta(it) < 0) & (eta(it+1) >= 0)  % ZUC
        jzuc       = jzuc + 1; 
        izuc(jzuc) = it; % Index of each ZUC time
        tend(jzuc) = t(it) + (dt/(eta(it+1)-eta(it)))*eta(it+1);
        Tint(jzuc) = tend(jzuc) - tstart;  % Individual ZUC wave period
        tstart     = tend(jzuc);
        Hint(jzuc) = etamax - etamin;      % Individual ZUC wave height
        Nst        = Nst + 1;
        etamax     = 0;
        etamin     = 0;
    end
end

% Wave parameters, wavemaker theory for individual ZUC waves

Lint  = ldis(Tint,h);    % Wavelength from linear dispersion relationship
%       ----
kint  = 2*pi./Lint;      % Wavenumber
kth   = kint*h;

% Flap wavemaker stroke amplitude
%++++++++++++++++++++++++++++++++

% fWMint S_n/H_n: function for periodic flap wavemaker theory applied to individual ZUC waves
% fWMint function  corrected for jack elevation (DD 1991; Eq. (6.25))

fWMint = (h0/(4*h))*(kth./sinh(kth)).*((sinh(2*kth)+2*kth)./(kth.*sinh(kth)-cosh(kth)+1));

S0int  = Hint.*fWMint;

% Enforces lower and upper bound on stroke based on wavemaker stroke function

for n=2:Nst
    Sfin(n-1) = S0int(n);  % Shift time series to the first ZUC
    Hfin(n-1) = Hint(n);  
    Tfin(n-1) = Tint(n); 
    
    S0min  = interp1(TV,S0V(1,:),Tint(n),'spline'); % Min stroke for this T, Vmin
    S0max  = interp1(TV,S0V(8,:),Tint(n),'spline'); % Max stroke for this T, Vmax

    if (S0int(n) > S0max) % Adjust stroke and H to upper bound
        Sfin(n-1) = S0max;
        Hfin(n-1) = S0max/fWMint(n);
    end
    if (S0int(n) < S0min)  % Adjust stroke and H to lower bound
        Sfin(n-1) = S0min;
        Hfin(n-1) = S0min/fWMint(n);
    end
end

tstr  = t(izuc) - t(izuc(1));              % beginning and end of each stroke (starts at 0)
tcor  = t(izuc(1):izuc(Nst))- t(izuc(1));         % new time series times
etacr = eta(izuc(1):izuc(Nst));                   % eta time series shifted to first ZUC
Nst   = Nst-1;                             % Nb. of strokes
Ntc   = length(tcor);

% Max voltage for each (trough to crest) stroke in ZUC analysis
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Note spline allows for T < 0.5 and > 2 s as individual wave periods
% and get a SO that is extrapolated

for n=1:Nst
    S0T(:) = interp2(Tgrid,Vgrid,S0V,V0V(:),Tfin(n),'spline');  % Range of stroke for this JS spectrum
    q      = polyfit(S0T,V0V,3);                                % Curve fit V(S) for given T values
    V0(n)  = polyval(q,Sfin(n));                                % Max voltage for Wavemaker control law
end

% Surface shape function and stroke/voltage functions time series
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Hfin    = [Hfin(1) Hfin];
V0all   = [V0(1) V0];
Sfin    = [Sfin(1) Sfin];
      
Hfinfit = interp1(tstr,Hfin,tcor,'linear','extrap');   %  Curve fit Hfin(waves)
izer    = find(Hfinfit == 0);
Hfinfit(izer) = 0.00001;

Sfinfit = interp1(tstr,Sfin,tcor,'linear','extrap');   %  Curve fit Sfin(waves)
V0fit   = interp1(tstr,V0all,tcor,'linear','extrap');  %  Curve fit V0(waves) 

Hfac = Hfin(1);
iac  = 1;
it   = 1;

% Final time series of S(t) and V(t)

while (it <= Ntc)   % for length of tcor and number of strokes     
    Shape(it)  = etacr(it)/Hfinfit(it);  % Time shape function alternative approach
    if it == 1
        Shape(it) = 0; % Make sure initial stroke/voltage is zero
    end
    Sfinal(it) = Sfinfit(it)*Shape(it);
    Vcal(it)   = V0fit(it)*Shape(it);
    it = it + 1;
end

% Spectral analysis of WM voltage (find freq. content)
%+++++++++++++++++++++++++++++++++++++++++++++++++++++

frint    = linspace(0,fra/2,NOMSP); % New freq. axis for interpolation 
dfint    = frint(2) - frint(1);
Trint    = 1./frint;
Trint(1) = 1000;

Vcaldm        = Vcal - mean(Vcal); % Demean voltage fct.
NP            = 256; % Nb. harmonics
[Vxx,FP]      = pwelch(Vcaldm,NP,NP/2,[],fra);
Vxx_Int       = interp1(FP,Vxx,frint,'spline'); % Reinterpolate spectrum
ineg          = find(Vxx_Int(1:NOMSP) < 0); % Eliminate spurious negative
Vxx_Int(ineg) = 0;    

[PVmax,ifp]   = max(Vxx_Int);   % Locate spectral max.
fp            = frint(ifp);     % Peak frequency
TpV           = 1/fp;

% Make figures
%+++++++++++++

if (pltall == 1)
    figure(1)
    plot(OMEGAN/(2*pi),SWAVE,'-b','Linewidth',1.5);   % spectral amplitude plot
    grid on
    xlabel({'$f$ (Hz)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$S$ (m$^2$.s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    xlim([0 3*OMEGAP/(2*pi)])    % Plot up to 3*f_p
    title(['Wave Power Spectrum (H_{s} = ' num2str(Hs,4) ' m ; T_p = ' num2str(Tp,4) ' s)'],'Fontsize',20);
    
    set(gca,'tickdir','out');set(gca,'FontSize',20);
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'LineWidth',1.5)
    set(gca,'FontName','Times New Roman')
    set(gcf,'Color','w');set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'Wave_S_spectrum'];
    rez    = 300; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);

    figure(2)
    plot(tcor,etacr,'-b','LineWidth',1.5) % time series shifted to first ZUC
    grid on
    xlabel({'$t$ (s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$\eta$ (m)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['Targeted elevation time series (H_{s} = ' num2str(Hs,4) ' m ; T_p = ' num2str(Tp,4) ' s)'],'Fontsize',20);
    
    set(gca,'tickdir','out');set(gca,'FontSize',20);
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'LineWidth',1.5)
    set(gca,'FontName','Times New Roman')
    set(gcf,'Color','w');set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'eta_tseries'];
    rez    = 300; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);

    figure(3)
    scatter(tstr,V0all,'ob','filled')
    hold on
    plot(tcor,V0fit,'-r','LineWidth',1.5)
    grid on
    xlabel('t (s)','Fontsize',20);
    ylabel('V (V)','Fontsize',20);
    title(['Max voltage time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
    set(gca,'FontSize',20);
    
    figure(41)
    scatter(tstr,Sfin,'ob','filled')
    hold on
    plot(tcor,Sfinfit,'-r','LineWidth',1.5)
    grid on
    
    xlabel('t (s)','Fontsize',20);
    ylabel('S (m)','Fontsize',20);
    title(['Max corrected stroke time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
    set(gca,'FontSize',20);

    figure(42)
    scatter(tstr,Hfin,'ob','filled')
    hold on
    plot(tcor,Hfinfit,'-r','LineWidth',1.5)
    hold off
    grid on
    
    xlabel('t (s)','Fontsize',20);
    ylabel('H (m)','Fontsize',20);
    title(['Max corrected wqve height time series (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
    set(gca,'FontSize',20);

    figure(5)
    plot(tcor,Vcal,'-b','LineWidth',1.5)
    grid on
    xlabel({'$t$ (s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$V_{WM}$ (V)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['Voltage time series (H_{s} = ' num2str(Hs,4) ' m ; T_p = ' num2str(Tp,4) ' s)'],'Fontsize',20);
    
    set(gca,'tickdir','out');set(gca,'FontSize',20);
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'LineWidth',1.5)
    set(gca,'FontName','Times New Roman')
    set(gcf,'Color','w');set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'WM_V_tseries'];
    rez    = 600; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);
    
    figure(6)
    plot(tcor,Sfinal,'-b','LineWidth',1.5)
    grid on
    xlabel({'$t$ (s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$S_{WM}$ (m)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['Target stroke time series (H_{s} = ' num2str(Hs,4) ' m ; T_p = ' num2str(Tp,4) ' s)'],'Fontsize',20);
    
    set(gca,'tickdir','out');set(gca,'FontSize',20);
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'LineWidth',1.5)
    set(gca,'FontName','Times New Roman')
    set(gcf,'Color','w');set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'WM_S_tseries'];
    rez    = 300; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);
    
    figure(43)
    plot(tcor,100*Shape,'-b','LineWidth',1.5)
    grid on
    xlabel('t (s)','Fontsize',20);
    ylabel('Scor (%)','Fontsize',20);
    title(['Stroke  by stroke correction (H_s = ' num2str(Hs) ' m ; h = ' num2str(h) ' m ; T_p = ' num2str(Tp) ' s)'],'Fontsize',20);
    set(gca,'FontSize',20);

    figure(7)
    plot(frint,Vxx_Int,'-b','Linewidth',1.5)
    grid on
    xlabel({'$f$ (Hz)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$P_V$ (V$^2$.s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['WM Voltage Power spectrum (H_{s} = ' num2str(Hs,4) ' m ; T_p = ' num2str(Tp,4) ' s)'],'Fontsize',20);
    xlim([0 3*fp]) % Plot up to 3*f_p
    
    set(gca,'tickdir','out');set(gca,'FontSize',20);
    set(gca,'XMinorTick','on','YMinorTick','on')
    set(gca,'LineWidth',1.5)
    set(gca,'FontName','Times New Roman')
    set(gcf,'Color','w');set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'WM_V_spectrum'];
    rez    = 300; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);
end

fid1   = fopen([outdir outfile],'w');
outvar = [tcor' Vcal' Sfinal'];
fprintf(fid1,'%12.7f %12.7f %12.7f\n',outvar(:,3));
fclose(fid1)
