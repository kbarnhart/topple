% sea ice prep for long model runs.
% takes as input a file 'seaice' with the day of year and year of on and
% off open water

function [iceon]=seaiceprep(varargin)

load('SEAICE.mat')

if length(varargin)==3

    tmin=varargin{1};
    tmax=varargin{2};
    dt=varargin{3};

    t=tmin:dt:tmax;

   
    % plot(ice(:,1), ice(:,2), '.')
    % datetick


elseif length(varargin)==1
    
    t=varargin{1};
    
end


zvec=zeros(size(year1));
year1=[year1 zvec zvec zvec zvec zvec];
year1=datenum(year1);

off=year1+firstday;
off0=[off zeros(size(off))];
off1=[off+.1 ones(size(off))];

on=year1+lastday;
on0=[on ones(size(on))];
on1=[on+.1 zeros(size(on))];

ice=[off0;off1;on0;on1];
ice=sortrows(ice);
   
iceon=round(interp1(ice(:,1), ice(:,2), t));

 end
