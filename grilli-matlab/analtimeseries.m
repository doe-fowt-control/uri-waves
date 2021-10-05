%      PROGRAM ANALTIMESERIES
%=========================================================================
%
%     Reads time series of experimental data for boat model testing and paddle.
%     Surface elevations (t,eta) at gauges and strong pot data at ship model, and similar for paddle 
%     in files (different decs, different sampling freq):
%     Filexp1: [t,g1,t,g2,t,g3,t,pt1,t,pt2,t,pt3]
%     Filexp2: [t S_target S_pot gain voltout]
%
%     For gauges, performs statistical analyses by zero-up-crossing (needs zeroup.m) and
%     computes a series of design wave charactersitics. Computes spectral
%     parameters and compares to statistics. Plots the various results.
%     Computes power spectrum and compares to target PM and obeerved data,
%     also fitted with a JS spectrum
%
%     3/20     S. GRILLI, Ocean Engng., Univ. of Rhode Island
%
%=========================================================================

clc; clear all; close all; 

global GE FETCH U10 AMPS OMEGAP ALPHA SWAVE AMP0 JSGAM EPSSP OMSMIN OMSMAX

% User supplied data
%+++++++++++++++++++

NWG            = 3;    % Total nb. of wave gauges used in experiments
Hs_target      = 0.03; % Target significant wve height in experiments (m)
Tp_target      = 1; 
NW_target      = 250;  % length of useful time series in Tp
NW_start       = 10;   % Number of waves in Tp to skip in time seriers to remove transient
NP             = 256;  % Frequencies in spectral analysis
NOMSP          = 1500; % Nb. of freq. for spectralinterpolation
ploteverything = 1;    % Plot if 1
spcolor        = ['y','r','b','g','p']; % Colors for spectra of WG 1, 2,...
strgage        = ["WG_1","WG_2","WG_3","WG_4","WG_5"];

% Data for fitting target JS spectrum

GE        = 9.81;
EPSSP     = 0.0002; % target spectrum truncation 

directo = '/Users/sgrilli/Documents/STEPHAN/CLASSES/OCE495-496/SENIOR-PROJECTS-19/Capstone_OCE496/';
dirtest = 'Test2_calib/';
Filexp1 = 'WG_JS_Hs3_Tp1_NW300_DP1p37_GN23_PO12.txt'; % File with gauge and pot data
Filexp2 = 'PAD_JS_Hs3_Tp1_NW300_DP1p37_GN23_PO12.txt'; % File with wavemaker paddle data

outdir  = [directo dirtest];

% Read experimental data
%+++++++++++++++++++++++

DATA1 = load([directo dirtest Filexp1]);  % Read exp. data file1
DATA2 = load([directo dirtest Filexp2]);  % Read exp. data file2

Time1(:) = DATA1(:,1); % Time series time (s)
for ng = 1:NWG
    VWG(:,ng) = DATA1(:,1+ng); % Voltage for NWgauge wave gauge time series (V)
end
VP_stern(:) = DATA1(:,NWG+2); % Stern string-pot voltage (V)
VP_bow(:)   = DATA1(:,NWG+3); % Bow string-pot voltage (V)

Time2(:)     = DATA2(:,1); % Time series time (s)
St_observ(:) = DATA2(:,2); % Paddle observed stroke (m)
St_target(:) = DATA2(:,3); % Paddle target at string-pot (m)

% Wave gauge analysis
%++++++++++++++++++++

% Get wave gauge calibration factors

WG_cal  = load([outdir 'wavecalib.mat']); % WG calibration structure
WG_fact = WG_cal.var';                    % Wave gauge calibration factors (should be NWgauge) (V/m)
NWG_use = length(WG_fact);                % Number of calibrated gauges are those in use

Eta_WG(:,1:NWG_use) = VWG(:,1:NWG_use)./WG_fact(1:NWG_use); % Wave gauge calibration 

% Truncate and detrend wave gauge time series

delt     = Time1(2) - Time1(1);                % Sampling interval for wave gauges
fra1     = floor(1./delt);                     % Sampling frequency for wave gauges
startpos = fra1*NW_start*Tp_target;            % truncate small transient => adjust
endpos   = min(length(Time1),startpos - 1 + fra1*NW_target*Tp_target);

t                      = Time1(startpos:endpos);              % Clip data to useful windows
npts                   = length(t);                           % Nb. of points in series
eta(1:npts,1:NWG_use)  = Eta_WG(startpos:endpos,1:NWG_use);   % Remove 2nd slideing LSM polynomial fit
ngol                   = 2*floor(npts/15) + 1;                % Dimension of sliding polynomial for MWL comput.
etam(:,1:NWG_use)      = sgolayfilt(eta(:,1:NWG_use),2,ngol); % SavGol method => MWL(t)
etadm(:,1:NWG_use)     = eta(:,1:NWG_use) - etam(:,1:NWG_use);
etam(:,1:NWG_use)      = etam(:,1:NWG_use) -  mean(etam(:,1:NWG_use)); % remove mean of MWL for plotting it

% ZUC analysis and statistics and spectral analysis
% (allows verifying sea state is convergeds to Rayleigh distribution)

frint    = linspace(0,fra1/2,NOMSP); % New freq. axis 
dfint    = frint(2) - frint(1);
Trint    = 1./frint;
Trint(1) = 1000;

for ng = 1:NWG_use  
    
    % ZUC of each wave gauge
    [height,amp_c,amp_t,period,nw,indt] = zeroup(etadm(:,ng),t(:));
%                                         ------
    % Individual wave statistics

    Hall(1:nw,ng) = height(1:nw);
    Tall(1:nw,ng) = period(1:nw);
    nwall(ng)     = nw;

    H_sort        = sort(height);          % Ascending sort
    T_sort        = sort(period);
    Hmax(ng)      = H_sort(nw);            % Observed statistics
    Tmax(ng)      = T_sort(nw);
    Hmean(ng)     = mean(H_sort);
    Tmean(ng)     = mean(T_sort);
    Trms(ng)      = sqrt(mean(period.^2));
    Hrms(ng)      = sqrt(mean(H_sort.^2));     
    Hszuc(ng)     = sqrt(2)*Hrms(ng);       % ZUC and spectral statistics based on RD
    i13           = floor(2*nw/3) + 1;
    H13(ng)       = mean(H_sort(i13:nw));
    T13(ng)       = mean(T_sort(i13:nw));
    HmaxRD(ng)    = 0.707*sqrt(log(nw))*Hszuc(ng);  % Theoretical Hmax
    
    % Compare to RD ratios
    H13sHmean     = H13(ng)/Hmean(ng);      % Vs 1.6  for theory
    HmaxsMnaxRD   = Hmax(ng)/HmaxRD(ng);    % Vs 1
    
    % Time series/spectral analysis
    
    [Pxx(:,ng),FP(:,ng)] = pwelch(etadm(:,ng),NP,NP/2,[],fra1);
    Pxx_Int(1:NOMSP,ng)  = interp1(FP(:,ng),Pxx(:,ng),frint(1:NOMSP),'spline'); % Reinterpolate spectrum
    ineg                 = find(Pxx_Int(1:NOMSP,ng) < 0); % Eliminate spurious negative
    Pxx_Int(ineg,ng)     = 0;    

    % Peak spectral values and chracteristics height/periods
    [Pamax,ifp]          = max(Pxx_Int(:,ng));   % Locate spectral max.
    fp                   = frint(ifp);           % Simple maximum => noisy
    fp = fp-0.5*dfint*(Pxx_Int(ifp+1,ng)-Pxx_Int(ifp-1,ng))/(Pxx_Int(ifp+1,ng)-2*Pxx_Int(ifp,ng)+Pxx_Int(ifp-1,ng));
    Tp(ng)               = 1/fp;                 % Spectral peak period
    m0_i(ng)             = trapz(frint(:),Pxx_Int(:,ng)); % Integrated smoothed spectrum
    Hm0_P(ng)            = 4*sqrt(m0_i(ng)); 
    Tpsp(ng)             = trapz(frint(:),Pxx_Int(:,ng).^4)/trapz(frint(:),frint(:).*Pxx_Int(:,ng).^4);    
    etavar(ng)           = mean(etadm(:,ng).^2); % From time series
    Hs(ng)               = 4*sqrt(etavar(ng));
    
    % Results on screen
    out(ng,:)              = [ng Hszuc(ng) Hm0_P(ng) Hs(ng) H13sHmean HmaxsMnaxRD Tmean(ng) Trms(ng) Tpsp(ng)];
end 

'ng    Hs,zuc      Hm0       Hs     H13/Hm     Hmax/HmaxRD      Tm       Trms      Tpsp'
for ng = 1:NWG_use  
    out(ng,:)
end

% Actual sea state parameters in tank

Hsm  = mean(Hs)
Tpm  = mean(Tpsp)

% Plot wave gauge elevation time series

if ploteverything == 1
    for ng = 1:NWG_use
        figure(ng)
        plot(t(:),etadm(:,ng),'k-',t(:),etam(:,ng),'r-','LineWidth',1);
        grid on
        
        set(gca,'tickdir','out')
        set(gca,'LineWidth',1)
        set(gcf,'Color','w')
        xlabel({'$t$ (s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
        ylabel({'$\eta$ (m)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
        title(['Surface elevation WG_' num2str(ng) ' (H_{m0} = ' num2str(Hsm,3) ' m ; T_p = ' num2str(Tpm,3) ' s)'],'Fontsize',20);
        set(gca,'FontSize',20);set(gca,'FontName','Times New Roman')
        set(gcf,'Units','centimeters','Position',[0,0,30,10])
        fig                   = gcf;
        fig.PaperUnits        = 'centimeters';
        fig.PaperPosition     = [0 0 30 10];
        fig.PaperPositionMode = 'manual';

        % Save figure
        fnameb = [outdir 'WG_eta_' num2str(ng)];
        rez    = 600; %resolution (dpi) of final graphic
        f      = gcf; %f is the handle of the figure you want to export
        figpos = getpixelposition(f); 
        resol  = get(0,'ScreenPixelsPerInch'); 
        set(f,'Renderer','ZBuffer')
        set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
        print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez
        print(f,[fnameb '.eps'],'-depsc',['-r',num2str(rez)],'-opengl') % save file at resolution rez

        savefig([fnameb '.fig']);
    end
end

% Plot observed spectra and avg. JS spectrum fit with gamma=1.5 and 2.5

% Fit JS spectrum

FETCH                = 0;  % -1 for PM, 0 for JS
U10                  = 0;
JSGAM                = 1.5;  % Average peakedness for JS (3) => adjusted for tank
AMPS                 = Hsm/2;
OMEGAP               = 2*pi/Tpm;
[AMPNO,PSINO,OMEGAN] = spectre13(NOMSP);
%                      ---------
SWAVEG15 = SWAVE; 

FETCH                = 0;  % -1 for PM, 0 for JS
U10                  = 0;
JSGAM                = 2.5;  % Average peakedness for JS (3) => adjusted for tank
AMPS                 = Hsm/2;
OMEGAP               = 2*pi/Tpm;
[AMPNO,PSINO,OMEGAN] = spectre13(NOMSP);
%                      ---------
SWAVEG25 = SWAVE; 

if ploteverything == 1
    figure
    for ng = 1:NWG_use
        plot(frint(:),Pxx_Int(:,ng),['-' spcolor(ng)],'Linewidth',1.5)
        hold on
    end
    plot(OMEGAN/(2*pi),2*pi*SWAVEG15,'--k',OMEGAN/(2*pi),2*pi*SWAVEG25,'--m','LineWidth',1.5)
    legstring = [strgage(1:NWG_use) "JS(1.5)" "JS(2.5)"];
    hold off
 
    grid on
    xlabel({'$f$ (Hz)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$S$ (m$^2$.s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['Power Spectra (H_{m0} = ' num2str(Hsm,3) ' m ; T_p = ' num2str(Tpm,3) ' s)'],'Fontsize',20);
    legend(legstring,'Fontsize',20);
    xlim([0 3*OMEGAP/(2*pi)]) % Plot up to 3*f_p
    
    set(gca,'tickdir','out');set(gca,'FontSize',20);
    set(gca,'LineWidth',1)
    set(gca,'FontName','Times New Roman')
    set(gcf,'Color','w');set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'WG_spectra'];
    rez    = 600; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);
end

% Analysis of Wavemaker motion
%+++++++++++++++++++++++++++++

% Narrow time window to active generation
ittarg = find (Time2 < NW_target*Tp_target); 
Smeant = mean(St_target(ittarg));
Smeano = mean(St_observ(ittarg));

% Statistics
Star_std = std(St_target(ittarg))
Sobs_std = std(St_observ(ittarg))
    
if ploteverything == 1
    Smax   = max(abs(St_target(ittarg))) - abs(Smeant);
    Srange = 1.1*Smax;
    
    figure
    plot(Time2(ittarg)',St_target(ittarg)-Smeant,'k-',Time2(ittarg)',St_observ(ittarg)-Smeano,'r-','LineWidth',1);
    grid on
    ylim([-Srange Srange]) 
    
    set(gca,'tickdir','out')
    set(gca,'LineWidth',1)
    set(gcf,'Color','w')
    xlabel({'$t$ (s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$S$ (m)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['Paddle Motion (H_{m0} = ' num2str(Hsm,3) ' m ; T_p = ' num2str(Tpm,3) ' s)'],'Fontsize',20);
    legend({'Target','Actual'},'Fontsize',20)
    set(gca,'FontSize',20);set(gca,'FontName','Times New Roman')
    set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'WM_S'];
    rez    = 600; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez
    print(f,[fnameb '.eps'],'-depsc',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);
end


