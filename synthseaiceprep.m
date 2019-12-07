% sea ice prep for long model runs.
% takes as input a file 'seaice' with the day of year and year of on and
% off open water

function [iceon]=synthseaiceprep(tmin, tmax, dt)

% for constant based on 1979-1985 mean and std
load SEAICE
   
t=tmin:dt:tmax;

zvec=zeros(size(year1));
year1=[year1 zvec zvec zvec zvec zvec];
year1=datenum(year1);

%%

mfirst=216.6667;
sdfirst=11.0030;

mlast=273.3333;
sdlast=6.4083;

firstday=random('norm', mfirst, sdfirst, size(year1)) ;
lastday=random('norm', mlast, sdlast, size(year1)) ;
%%


off=year1+firstday;
off0=[off zeros(size(off))];
off1=[off+.1 ones(size(off))];

on=year1+lastday;
on0=[on ones(size(on))];
on1=[on+.1 zeros(size(on))];

ice=[off0;off1;on0;on1];
ice=sortrows(ice);

% plot(ice(:,1), ice(:,2), '.')
% datetick

iceon=round(interp1(ice(:,1), ice(:,2), t));


 end
