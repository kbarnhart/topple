

close all 
clear all


load ../topple3/observedDrivers
save('ObservedDrivers')

% water level was ajusted, 

load ObservedPaper1/whMethod_NoChanges.mat;
newWL=water_height;
save('newWL', 'newWL')

clear all
load newWL


load ObservedDrivers
h=newWL;
clear newWL

save('ObservedDrivers')



