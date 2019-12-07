close all
clear all
load fastTest



exposure=water_height.*m/24;
exposure(exposure<0)=0;
exposure(isnan(exposure))=0;

cumulativeExposure=cumsum(exposure);


f1=figure;

set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [3 2.25 3.5 3]);
% set(gcf, 'Units', 'inches', 'OuterPosition',[2 1  8 6]);

subplot(2,1,1)
line(t,exposure,'Color','k')
datetick
xlabel('Time','FontSize', 8)
ylabel('Exposure [m^{2}/day]','FontSize', 8)

hold on
ax1=gca;

ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'XTick',[],...
           'Color','none',...
           'XColor','k','YColor','k');
line(t, cumulativeExposure,'Color','r','Parent',ax2);
ylabel('Cumulative Exposure [m^{2}]','FontSize', 8)

linkaxes([ax1, ax2], 'x')
       

subplot(2,1,2)
yrs=1979:2011;

for i=1:numel(yrs)
   yr=yrs(i);
   
   inds=find(year(t)==yr);
   vals=exposure(inds);
   cumYearExposure(i)=sum(vals);
end

bar(yrs,cumYearExposure)
xlabel('Year','FontSize', 8)
ylabel('Cumulative Exposure by Year [m^{2}]','FontSize', 8)


print(f1, '-depsc',  'Exposure') 

