% sea ice prep for long model runs.
% takes as input a file 'seaice' with the day of year and year of on and
% off open water

function [iceon]=futureseaice(tmin, tmax, dt)

% future sea ice from 

 fdp1=-0.7281;
 fdp2=1664;
 
 ldp1=0.7917; 
 ldp2=-1293;
 
 mfirstrem=  -0.0926;
 sfirstrem= 13.5295;
 
 mlastrem= -0.2804;
 slastrem=13.0321;
   
t=tmin:dt:tmax;
yearstart=floor(tmin); [yearstart, ~, ~, ~, ~, ~ ]=datevec(yearstart);
yearend=ceil(tmax);[yearend, ~, ~, ~, ~, ~ ]=datevec(yearend);
year1=yearstart:yearend';
year1=year1';

firstday=year1.*fdp1+fdp2+random('norm', mfirstrem, sfirstrem, size(year1));
lastday=year1.*ldp1+ldp2+random('norm', mlastrem, slastrem, size(year1));
 %%
firstpred=year1.*fdp1+fdp2;
lastpred=year1.*ldp1+ldp2;


firstrem=firstday-firstpred;
lastrem=lastday-lastpred;

subplot(5,1,1:3)

plot(year1, firstpred, 'g', year1, lastpred, 'r')
legend('First Open Water Day', 'Last Open Water Day', 'Duration of Sea Ice Free Days')

hold on

plot(year1, lastday, 'k.')
plot(year1, firstday, 'k.')

for i=1:numel(year1)
    plot([year1(i) year1(i)], [firstday(i) lastday(i)], 'k')
end
ylabel ('Day of Year')
axis([yearstart yearend 0 365])
plot(year1, lastday-firstday, 'ko')


subplot(5,1,5)
bar(year1, firstrem, 'g')
axis([yearstart yearend -60 60])

subplot(5,1,4)
bar(year1, lastrem, 'r')
ylabel ('Residual from Linear Fit')
axis([yearstart yearend -60 60])

xlabel('Year')

%%
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
