% create "cumulativeHeight.mat"
close all
clear all


load longTermRunConditions

startDay=datenum([1986 1 1 0 0 0]);
stopDay=datenum([1986 7 30 13 0 0]);
inds=find(t>startDay&t<stopDay);



height=water_height+1.5.*waveheight;
height(inds)=0;
height(isnan(height))=0;
height(height<0)=0;

cumHeight=cumsum(height);

posLevel=height>0;
 
cumTouchBluff=cumsum(posLevel);


%plotyy(t, cumHeight, t, cumTouchBluff)
figure
a1=subplot(2,1,1);
plot(t, cumHeight,'.-')
hold on
plot(t(inds), cumHeight(inds), 'r.')
datetick

a2=subplot(2,1,2);
plot(t, height,'.-')
hold on
plot(t(inds), height(inds), 'r.')


linkaxes([a1 a2],'x')

save('cumulativeHeight', 'cumHeight', 'cumTouchBluff')