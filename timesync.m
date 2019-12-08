function [varargout] = timesync(timetype, cuttype, interptype, varargin) 
% written by k. barnhart spring 2011

% this function will synchronize any number of time series. 
% time vector and dependent vector should be entered in that order, in
% pairs
% e.g.

% [t1new d1new t2new d2new t3new d3new]= timesynch('max', 'full', 'linear' , t1, d1, t2, d2, t3, d3)

% if the number of time series is even the script will choose either the
% max or min timestep (depending on timetype input).

% if the number of time series is odd, the final input variable (t4 in the
% example below) is assumed to be the series of timesteps. I have included
% this option to allow for the timeseries to be synched with a time vector
% that may not have an associated meteorological timeseries (e.g. times at
% which a picture was taken. 

% e.g.
% [t1new d1new t2new d2new t3new d3new]= timesynch('max', 'full', 'linear', t1, d1, t2, d2, t3, d3, t4)

% timetype options -- which timestep should be used
% 'max'
% 'min', defaut
% 
% cuttype options -- should the time series be cut to where they overlap? 
% 'full'
% 'cut'

% interptype options-- same as for the function interp1 (below is copied
% from the help documentation
% 'nearest' -- Nearest neighbor interpolation
% 'linear'-- Linear interpolation (default)
% 'spline'-- Cubic spline interpolation
% 'pchip'-- Piecewise cubic Hermite interpolation 
% 'cubic'--(Same as 'pchip') 
% 'v5cubic'-- Cubic interpolation used in MATLAB 5. This method does not extrapolate. Also, if x is not equally spaced, 'spline' is used/



% in this program, whenever the time series is extrapolated out of the
% collected time series (in the case of the 'full' cuttype), values for the
% time series where original data does not exist are written as 999.99

% This holds for both the interpolation methods that interp1 will return
% NaN for values outside of the x-vector, and for interpolation menthods
% where interp1 will extrapolate. 

if rem(numel(varargin), 2)~=0;
    varargout=cell(numel(varargin)-1,1);
    a=(numel(varargin)-1)/2;
else
    varargout=cell(numel(varargin),1);
    a=numel(varargin)/2;
end

% determine the times at which the script will return synched series. 
if rem(numel(varargin), 2)~=0;
%     Option: use a specified time series (the last argument in)
    t=varargin{end};    
       
else
    
    %determine the timestep to be used 
    dt=zeros(1,a);
    for i=1:a
        dt(i)=varargin{2*i-1}(2)-varargin{2*i-1}(1);
    end
   
    if strcmpi(timetype, 'max')
        dt_step=max(dt);
    else
       dt_step=min(dt);
    end
  
    tind=find(dt==dt_step);
    if numel(tind)>1 % if more than one index has the same timestep (and it is chosen)
       tind=tind(1); 
    end
    
    % set the time vector for to the one with the correct timestep; 
    t=varargin{tind*2-1};
    
end
 %determine each time min and max
 tmin=zeros(1,a);
 tmax=zeros(1,a);

 for i=1:a
       tmin(i)=min(varargin{2*i-1});
       tmax(i)=max(varargin{2*i-1});
 end
    
% Option: cut the time series to where all data overlaps
    if strcmpi(cuttype, 'cut')
        tmin=max(tmin);
        tmax=min(tmax);
        t=t(t>=tmin&t<=tmax);
   
   % Option: make the time series from the first record to the last record,
   % without regard to if all series have observations at those times. 
    elseif strcmpi(cuttype, 'full')
       tmin=min(tmin);
       tmax=max(tmax);
       if rem(numel(varargin), 2)==0;
            t=tmin:dt(tind):tmax;
       end
    end
   
    
 % Use selected timeseries to interpolate all series
 for i=1:a;
     varargout{2*i-1}=t;
     varargout{2*i}=interp1(varargin{2*i-1}, varargin{2*i}, t, interptype);
     nodata= t>max(varargin{2*i-1})| t<min(varargin{2*i-1});
     varargout{2*i}(nodata)=999.99;
 end
        

end