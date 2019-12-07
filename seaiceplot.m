% sea ice plots\\
close all
clear all
load SEAICE
% curve fit parameters for first last and duration
 dp1=1.52;
 dp2=-2957;

 fdp1=-0.7281;
 fdp2=1664;
 
 ldp1=0.7917; 
 ldp2=-1293;
%%%%

firstpred=year1.*fdp1+fdp2;
lastpred=year1.*ldp1+ldp2;
durpred=year1.*dp1+dp2;

firstrem=firstday-firstpred;
lastrem=lastday-lastpred;
durrem=duration-durpred;


subplot(6,1,1:3)

plot(year1, firstpred, 'g', year1, lastpred, 'r', year1, durpred, 'b')
legend('First Open Water Day', 'Last Open Water Day', 'Duration of Sea Ice Free Days')

hold on

plot(year1, lastday, 'k.')
plot(year1, firstday, 'k.')

for i=1:numel(year1)
    plot([year1(i) year1(i)], [firstday(i) lastday(i)], 'k')
end
ylabel ('Day of Year')
axis([1977 2010 0 365])
plot(year1, lastday-firstday, 'ko')


subplot(6,1,5)
bar(year1, firstrem, 'g')
axis([1977 2010 -60 60])

subplot(6,1,4)
bar(year1, lastrem, 'r')
ylabel ('Residual from Linear Fit')
axis([1977 2010 -60 60])

subplot(6,1,6)
bar(year1, durrem, 'b')
axis([1977 2010 -60 60])

xlabel('Year')
 

figure(2)

subplot(3,1,2)
hist(firstrem,4)
subplot(3,1,1)
hist(lastrem,4)
subplot(3,1,3)
hist(durrem,4)

figure(3)
plot(firstrem, lastrem, 'k*')
xlabel ('First Day Residual')
ylabel ('Last Day Residual')

%%%%%%%%%%
% figure(2)
% 
% cutoff=6;
% 
% fhfirst=firstday(1:cutoff);
% fhlast=lastday(1:cutoff);
% fhdurd=duration(1:cutoff);
% 
% lhfirst=firstday(cutoff+1:end);
% lhlast=lastday(cutoff+1:end);
% lhdur=duration(cutoff+1:end);
% 
% % 
% % boxplot(fhfirst,'notch','on',...
% %         'labels',{'first half'})
%     hold on
% boxplot(lhfirst,'notch','on',...
%         'labels',{'first half'})
% boxplot(firstday,'notch','on',...
%         'labels',{'first half'})

% hist(fhfirst)
% hold on
% hist(lhfirst)
% hist(firstday)