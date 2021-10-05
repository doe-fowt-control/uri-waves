%      PROGRAM POTCALIB
%=========================================================================
%
%     Reads ...
%
%     3/20     S. GRILLI, Ocean Engng., Univ. of Rhode Island
%
%=========================================================================

clc; clear all; close all; 

% User supplied

directo  = '/Users/sgrilli/Documents/STEPHAN/CLASSES/OCE495-496/SENIOR-PROJECTS-19/Capstone_OCE496/';
directop = 'PotentiometerCalibrations/Blue_Pot_Cal/';
Filepos  = 'positions.txt';

gaglabel = {'yelcal';'redcal';'blue'};
potlabel = {'YelPot';'RedPot';'BluePot'};
potdata  = load([directo directop Filepos]);  % Read pot. position file in cm
potdata  = potdata/100;
npdata   = length(potdata);
%npdata   = 13; % Truncate there for now

for ng = 3:3
    gname = gaglabel{ng};

    for ip = 1:npdata
        fname = [directo directop gname num2str(ip-1) '.lvm'];
        DATA  = load(fname);
        Vdata(ng,ip) = mean(DATA(:,7)); % Mean pot voltage (V)
    end
    
    % Linear fit for gauge ng
    [potcal(ng,:),Sp(ng)] = polyfit(potdata(1:npdata)',Vdata(ng,1:npdata),1); % Linear fit coefficients A and B: V = A x^1 + B x^0
    
    % Fit error indicator for gauge ng
     Vfit   = polyval(potcal(ng,:),potdata(1:npdata),Sp(ng));
     ymean  = mean(Vdata(ng,1:npdata));
     STC    = sum((Vdata(ng,1:npdata) - ymean).^2);
     SCR    = sum((Vdata(ng,1:npdata)' - Vfit(1:npdata)).^2);
     R2(ng) = 1 - SCR/STC;
end

% Outpout results on screen
'A         B         R^2 (V = A x^1 + B x^0)'
[potcal R2']

figure
scatter(potdata(1:npdata),Vdata(ng,1:npdata),'ro')
hold on
plot(potdata(1:npdata),Vfit,'-k','LineWidth',1.5')
grid on
xlabel({'$z$ (m)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
ylabel({'$V_p$ (V)'},'FontSize',20,'FontName','Times New Roman','Interpreter','latex');
    


% Save calibration factors of gauges
fname = [directo directop 'potcaliblue.mat'];
var   = potcal(:,1);
save(fname,'var');

% Result is B=7.4545 with R2=0.9992


