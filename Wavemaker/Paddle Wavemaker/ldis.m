 function [L] = ldis(T,H)                                      
%---------------------------------------------------------------------- 
%0  LDISF     ldis                                                     
%1  Purpose   ldis computes the wavelength L using the linear dispersion 
%1            relation : k tanh(k*d) = (omega)**2 / ge  in the form
%1            L = Lo tanh(k*h), with Lo=g T**2/2 pi
%2  Method    Newton-Raphson iteration method with relative error EPS 
%2            Computations assume SI, i.e., MKS units.   
%2            Uses : x = k*h; k=2 pi/L
%2                   x(n+1)   = x(n) - F(x(n))/DF(x(n))
%2                   F(x(n))  = x(n) - D/tanh(x(n))
%2                   DF(x(n)) = 1 + D/sinh(x(n))**2  
%2            Number of iterations is limited to ITERM=50 
%3  CALL arg. T    :   Wave period (s)
%3            H    :   Depth of the sea (m)     
%3  RET arg.  L    :   Wavelength (m)                                   
%3  OTHERS    g    :   Acceleration of gravity (m/s^2)                          
%E  ERRORS    The number of iterations is too large                  
%9  March 00  S. Grilli, Ocean Engng. Dept., Univ. of Rhode Island    
%L              
%-----------------------------------------------------------------------
%
      g    = 9.81;     %m/s^2
      EPS   = 0.000001;
      ITERM = 50;               
%                                                                       
      OMEGA = 2 .*pi ./ T;
      D     = (OMEGA.^2) .* H ./ g;
      ITER  = 0;  
      ERR   = 1;
%
%.....Initial guess for nondimensional solution X
%                                  
      if (D >= 1) 
         X0 = D;
      else
         X0 = sqrt(D);
      end 
%
%.....Solution using Newton-Raphson method
%                    
      while ((ERR > EPS) & (ITER <= ITERM))
         F    = X0 - D./tanh(X0);
         DF   = 1 + D./(sinh(X0).^2);
         X1   = X0 - F./DF;
         ERR  = abs((X1-X0)./X0);
         X0   = X1;
         ITER = ITER + 1;
      end
%
      if (ITER > ITERM) 
         fprintf(1,'convergence failed\r');                        
      else
         L = 2 .* pi .*H ./ X1;
      end                               