function [AMPN,PSIN,OMEGAN] = spectre13(NOMSP)
%=========================================================================
% PM: FETCH = -1; U10=0 HSTARG = 0 => use OMEGAP, find U10 and HS0 
%                              > 0 => use HSTARG, find U10 and OMEGAP
%                 U10>0 HSTARG = 0 => use  U10, find OMEGAP and HS0 
%                              
% JS: FETCH >0  U10>0     => use U10 & FETCH,    find OMEGAP, ALPHA 
%     FETCH =0  U10=0     => use OMEGAP & HS,    find U10,FETCH 
%     FETCH >0  U10=0     =>  use OMEGAP & FETCH, find U10, Hs   
%      
% Choose between original JONSWAP Hasselman's formula or more recent Donelan formula          
%     FHA = 1: Hasselman's (1973) formulation
%           2: Donelan et al (1985)
%=========================================================================
global GE FETCH U10 AMPS OMEGAP ALPHA SWAVE AMP0 JSGAM EPSSP OMSMIN OMSMAX

OMEGA1  = 0.1;   %	Low Frequency cut off (20s, 624 m DW)
OMEGA2  = 39.95;    %	High frequency cutoff (.1s, 1.56 cm DW)
NOMEGT  = 1000;    %    Number of frequencies for initial spect. analysis
FHA     = 2;       % (1: Hasselman's (1973) formulation; 2: Donelan et al (1985) formulation)

if (FHA == 1)
    CA = 0.0760; CB = 0.22; CC = 22; CD = 0.33; C2 = 0.010; C3 = 0.66;
end
if (FHA == 2)
   CA = 0.0204; CB = 0.12; CC = 11.6; CD = 0.23; C2 = 0.006; C3 = 0.50;
end

if U10 == 0
    if FETCH == -1 % FDS
        ALPHA = 0.0081;  % PM         
        if AMPS == 0
            U10   = 0.877*GE/OMEGAP;
            AMPS  = 0.1047*U10^2/GE;
        else
            U10   = sqrt(GE*AMPS/0.1047);
            OMEGAP= 0.877*GE/U10;
        end
        st    = 1;
    else 
        if FETCH > 0
            DEN = 1 - 2*CD;  
            U10   = (CC^(1/DEN) * GE^((1-CD)/DEN))/(FETCH^(CD/DEN) * OMEGAP^(1/DEN));  % JS (F,Tp) 
            ALPHA = CA/(GE*FETCH/U10^2)^CB;
            st    = 4;
        end
        if FETCH == 0
            st=2;
        end
    end    
else
    if FETCH == -1 %FDS
        ALPHA  = 0.0081;   % PM
        
        OMEGAP = 0.877*GE/U10;
        AMPS   = 0.1047*U10^2/GE;
        st     = 1;
    else
        ALPHA  = CA/(GE*FETCH/U10^2)^CB;  % JS (U10,F) given
        OMEGAP = (CC*GE/U10)/((GE*FETCH/(U10^2))^CD);
        st     = 3;
    end
end

% Spectrum generation at given frequencies 
% ----------------------------------------

% Calculate spectrum over pre-fixed interval [OMEGA1,OMEGA2] with max
% number of frequencies NOMEGT

OMEGAM(1:1:NOMEGT) = OMEGA1 + (0:1:NOMEGT-1)*(OMEGA2-OMEGA1)/(NOMEGT-1); 
XOM = OMEGAM/OMEGAP;  % nondimensional frequency
S0L = exp(-1.25./XOM.^4)./XOM.^5;  % PM basis

if st >= 2       % JS  correction
    GAMMA = JSGAM; 
    sig0L(1:NOMEGT) = 0.09;  
    nlittle         = find(XOM <= 1);
    sig0L(nlittle)  = 0.07;
    SWAVEL = S0L.*GAMMA.^(exp(-(XOM-1).^2./(2.*sig0L.^2)));
else
    SWAVEL = S0L;  % PM alpha value is already known
end

if st == 2  %  JS (As,Tp)
    
  %  Find JS as a function of (FETCH,U10)  to match  targeted As and Tp

  lambda = trapz(XOM(1:NOMEGT),SWAVEL(1:NOMEGT));  % Close to 0.3 for selected parameters
  ALPHA  = AMPS*AMPS*(OMEGAP^4)/(4*lambda*GE*GE);  
end

% final JS and PM spectrum over large frequency axis

SWAVEL = SWAVEL*ALPHA* GE^2 /OMEGAP^5;

% Find frequency interval [OMEGMIN,OMEGMAX] for spectrum > EPS its maximum 

[Smax,iSmax]  = max(SWAVEL);
ismall        = find(SWAVEL >= Smax*EPSSP);
OMSMIN        = min(OMEGAM(ismall));
OMSMAX        = max(OMEGAM(ismall));

% Recalculate spectrum in selected interval and its zero-th moment with
% reduced number of frequencies NOMEG

DOMEG = (OMSMAX-OMSMIN)/(NOMSP-1);  % final constant frequency interval
OMEGAN(1:1:NOMSP) = OMSMIN + (0:1:NOMSP-1)*DOMEG; 
XON = OMEGAN/OMEGAP;  % nondimensional frequency
S0   = exp(-1.25./XON.^4)./XON.^5;  % PM basis

if st >= 2       % JS  correction
    sig0(1:NOMSP)   = 0.09;  
    nlittle       = find(XON <= 1);
    sig0(nlittle) = 0.07;
    SWAVE = S0.*GAMMA.^(exp(-(XON-1).^2./(2.*sig0.^2)));
else
    SWAVE = S0;  % PM
end

if st == 2  %  JS (As,Tp)
    
%  Find JS as a function of (FETCH,U10)  to match  targeted As and Tp

   lambda = trapz(XON(1:NOMSP),SWAVE(1:NOMSP));  % Close to 0.3 for selected parameters
   ALPHA  = AMPS*AMPS*(OMEGAP^4)/(4*lambda*GE*GE);  
   OMP    = (ALPHA/C2)^(1/C3);  % nondim. peak freq.
   U10    = GE*OMP/OMEGAP   %  wind speed
   FETCHP = (CC/OMP)^(1/CD); 
   FETCH  = FETCHP * U10^2 / GE
end

% final JS and PM spectrum and parameters  

SWAVE = SWAVE*ALPHA * GE^2 /OMEGAP^5;

m0    = trapz(OMEGAN(1:NOMSP),SWAVE(1:NOMSP));   
AMP0 = 2*sqrt(m0)

% Free surface representation by random phase method based on spectrum
% --------------------------------------------------------------------

%  Random phase method

AMPN = sqrt(2.*SWAVE*DOMEG);
PSIN = 2*pi*rand(1,NOMSP);

m0     = sum(SWAVE*DOMEG);  % Final spectral parameters
AMPIRR = 2*sqrt(m0)

if (AMPS == 0) 
    AMPS = AMP0;
end

