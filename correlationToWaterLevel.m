% how well is erosion correlated to water level. 
close all
clear all

addpath '/Users/katherinebarnhart/MATLABwork/topple4/paperFullRun08'

figure

load rhMethod_FullRunNoChange

water_height(isnan(water_height))=0;
touchBluff=water_height>0;
cumTouchBluff=cumsum(touchBluff);
posHeights=touchBluff.*water_height;
cumHeight=cumsum(posHeights);

subplot(2,1,1)
title('Russel-Head Formulation')
[AX,H1,H2]=plotyy(t, topofbluff, t, cumHeight);
datetick     

subplot(2,1,2)
[AX,H1,H2]=plotyy(t, topofbluff, t, cumTouchBluff);



load whMethod_FullRunNoChange

water_height(isnan(water_height))=0;
touchBluff=water_height>0;
cumTouchBluff=cumsum(touchBluff);
posHeights=touchBluff.*water_height;
cumHeight=cumsum(posHeights);

subplot(1,3,2)
[AX2,H21,H22] =plotyy(t, topofbluff, t, cumHeight);
plot(get(AX1), t, cumTouchBluff, 'k')
datetick

load krMethod_FullRunNoChange

water_height(isnan(water_height))=0;
touchBluff=water_height>0;
cumTouchBluff=cumsum(touchBluff);
posHeights=touchBluff.*water_height;
cumHeight=cumsum(posHeights);

subplot(1,3,3)

[AX3,H31,H13] = plotyy(t, topofbluff, t, cumHeight);

for i=1:2
linkaxes([AX1(i) AX2(i) AX3(i)])
end