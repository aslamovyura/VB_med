function y = wthresh_our(x,sorh,t1, t2)
%WTHRESH Perform soft or hard thresholding. 
%   Y = WTHRESH(X,SORH,T) returns soft (if SORH = 's')
%   or hard (if SORH = 'h') T-thresholding  of the input 
%   vector or matrix X. T is the threshold value.
%
%   Y = WTHRESH(X,'s',T) returns Y = SIGN(X).(|X|-T)+, soft 
%   thresholding is shrinkage.
%
%   Y = WTHRESH(X,'h',T) returns Y = X.1_(|X|>T), hard
%   thresholding is cruder.
%
%   See also WDEN, WDENCMP, WPDENCMP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 24-Jul-2007.
%   Copyright 1995-2007 The MathWorks, Inc.

switch sorh
    %Unused soft
  case 's'
    tmp = (abs(x)-t);
    tmp = (tmp+abs(tmp))/2;
    y   = sign(x).*tmp;
 
  case 'h'
      for i = 1:length(x)
          if abs(x(i))>t1 && abs(x(i))<t2
            y(i)   = x(i).*(abs(x(i)));
          else
            y(i) = 0;
          end
      end
 
  otherwise
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end
