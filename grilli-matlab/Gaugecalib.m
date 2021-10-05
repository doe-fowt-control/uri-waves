%      PROGRAM GAUGECALIB
%=========================================================================
%
%     Reads :
%     GaugeCalibrationDATA.lvm: [t(s) g1(V) g2(V) g3(V) p1(V) p2(V) p3(V)]
%     potcalib.mat: [ cal_pot1 cal_pot2 cal_pot3 ] (V/m) in directory 
%     Writes :
%     wavecalib.mat : [ cal_g1 cal_g2 cal_g3 ] (V/m)
%     Nplateau : User supplied number of jumps (Nb plateau - 1) in calib
%
%     3/20     S. GRILLI, Ocean Engng., Univ. of Rhode Island directop
%
%=========================================================================

clc; clear all; close all; 

% User supplied

directo  = '/Users/sgrilli/Documents/STEPHAN/PROJECTS/CURRENT/CREARE-SBIR-17_awarded/WORK/Forward_speed_TEST/ANALYSIS';
directop = '/PotentiometerCalibrations/';
dirtest  = '/';  % Where test data is and results are stored
outdir   = [directo dirtest];
Nplateau = 18;

% Read pot calibration factors
potcalft = load([directo directop 'potcalib.mat']);

% Read Gauge calibration data
%fid      = fopen([directo dirtest 'WG_calibration_March19_18steps.lvm']);
fid      = fopen([outdir 'calibration_WG2.lvm']);

%gaugecal = textscan(fid, '%f%f%f%f%f%f%f', 'HeaderLines', 23, 'delimiter',',');
gaugecal = textscan(fid,'%f%f%f%f%f%f%f');
fclose(fid);

Time   = gaugecal{:,1};
npts   = length(Time);

% Find plateaux using time reset to 0
itim0  = find(Time == 0);
idchpt = [itim0' npts];
nidcpt = length(idchpt);
tidchp(1:nidcpt) = Time(idchpt)

for ng = 2:2
    wagraw = gaugecal{:,1+ng};    % Raw wave gauge voltage for ng (V)
    potraw = gaugecal{:,4+ng};    % Raw pot voltage for ng
    xptraw = potraw/potcalft.var(ng); % Pot x for ng (m)
    
    figure
    plot(xptraw,wagraw,'b-')
    
    %idchpt = findchangepts(xptraw,'MaxNumChanges',Nplateau);
    %idchpt = [1 idchpt' npts];
    %nidcpt = length(idchpt);
    %tidchp(1:nidcpt,ng) = Time(idchpt);
    
    for ni = 2:nidcpt
        wagcal(ni-1) = mean(wagraw(idchpt(ni-1):idchpt(ni)-1));
        xptcal(ni-1) = mean(xptraw(idchpt(ni-1):idchpt(ni)-1));
    end
    
    % Linear fit for gauge ng
    [wagpol(ng,:),Sg(ng)] = polyfit(xptcal(1:nidcpt-1),wagcal(1:nidcpt-1),1); % Linear fit coefficients A and B: V = A x^1 + B x^0
    
    % Fit error indicator for gauge ng
    yfit   = polyval(wagpol(ng,:),xptcal(1:nidcpt-1),Sg(ng));
    ymean  = mean(wagcal(1:nidcpt-1));
    STC    = sum((wagcal(1:nidcpt-1) - ymean).^2);
    SCR    = sum((wagcal(1:nidcpt-1) - yfit(1:nidcpt-1)).^2);
    R2(ng) = 1 - SCR/STC;
    
    % Plot raw wave gauge data
    figure
    plot(Time,wagraw,'-b','LineWidth',1.5)
    grid on
    set(gca,'tickdir','out')
    set(gca,'LineWidth',1)
    set(gcf,'Color','w')
    xlabel({'$t$ (s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$V_g$ (V)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['Calibration voltage at WG_' num2str(ng)],'Fontsize',20);
    set(gca,'FontSize',20);set(gca,'FontName','Times New Roman')
    set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'WG_V_' num2str(ng)];
    rez    = 600; %resolution (dpi) of final graphic
    f      = gcf; %f is the handle of the figure you want to export
    figpos = getpixelposition(f); 
    resol  = get(0,'ScreenPixelsPerInch'); 
    set(f,'Renderer','ZBuffer')
    set(f,'paperunits','inches','papersize',figpos(3:4)/resol,'paperposition',[0 0 figpos(3:4)/resol]); 
    print(f,[fnameb '.jpg'],'-djpeg',['-r',num2str(rez)],'-opengl') % save file at resolution rez
    print(f,[fnameb '.eps'],'-depsc',['-r',num2str(rez)],'-opengl') % save file at resolution rez

    savefig([fnameb '.fig']);
    
    % Plot calibrated raw pot data
    figure
    plot(Time,xptraw,'-b','LineWidth',1.5)
    grid on
    set(gca,'tickdir','out')
    set(gca,'LineWidth',1)
    set(gcf,'Color','w')
    xlabel({'$t$ (s)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    ylabel({'$z_p$ (m)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    title(['Calibration potentiometer position at WG_' num2str(ng)],'Fontsize',20);
    set(gca,'FontSize',20);set(gca,'FontName','Times New Roman')
    set(gcf,'Units','centimeters','Position',[0,0,30,10])
    fig                   = gcf;
    fig.PaperUnits        = 'centimeters';
    fig.PaperPosition     = [0 0 30 10];
    fig.PaperPositionMode = 'manual';

    % Save figure
    fnameb = [outdir 'PT_z_' num2str(ng)];
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

% Outpout results on screen
'A         B         R^2 (V = A x^1 + B x^0)'
[wagpol R2']

'Times of plateaux'
tidchp

% Save calibration factors of gauges
fname = [outdir 'wavecalib.mat'];
var   = wagpol(:,1);
save(fname,'var');


