close all
clear all
load /Users/katherinebarnhart/MATLABwork/drewpointdataingest/all_drewpoint_data.mat
load /Users/katherinebarnhart/MATLABwork/WindAnalysis/PrudhoeDataNOAA/NOAA_PRUDHOE
load /Users/katherinebarnhart/MATLABwork/SSTTrends/modeledTemperaturesJan2013.mat

figure
hold on

plot(wTemp.date, (wTemp.T-32).*5/9, levellogger.date, levellogger.watertemp)
plot(sst_wavelog.date, sst_wavelog.tempWL2, 'r')


plot(SSTModel.date, SSTModel.Twater, 'm')
legend('prudhoe noaa record', 'levellogger observations', 'wave logger observations', 'modeled temps')