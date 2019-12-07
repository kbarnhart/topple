% sea ice prep for long model runs.
% takes as input a file 'seaice' with the day of year and year of on and
% off open water

function [iceon]=shortseaiceprep(varargin)

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


% new first and last days
newfirstday=ones(size(firstday)).*223; % these are the 1979 intercepts for the curve fit that irina did. 
newlastday=ones(size(firstday)).*269;

zvec=zeros(size(year1));
year1=[year1 zvec zvec zvec zvec zvec];
year1=datenum(year1);

off=year1+newfirstday;
off0=[off zeros(size(off))];
off1=[off+.1 ones(size(off))];

on=year1+newlastday;
on0=[on ones(size(on))];
on1=[on+.1 zeros(size(on))];

ice=[off0;off1;on0;on1];
ice=sortrows(ice);
   
iceon=round(interp1(ice(:,1), ice(:,2), t));

 end
