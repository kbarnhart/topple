close all
clear all
load /Users//katherinebarnhart/MATLABwork/drewpointdataingest/all_drewpoint_data.mat
load /Users/katherinebarnhart/MET_stations/npra2/proc_data/AK100
load /Users/katherinebarnhart/MATLABwork/WindAnalysis/BRWmetdata/hrAvgBRW
load /Users/katherinebarnhart/MATLABwork/drewpointdataingest/UCBHourly.mat
t=tsdnc{1,1};

%%
figure
hold on

plot(hrAvgBRW.date, hrAvgBRW.T2m)
plot(t ,Tair,'r')
plot(UCBHourly.date, UCBHourly.airtempavg,'g')
datetick
xlabel('Time')
ylabel('Air Temperature (C)')
legend('Barrow', 'Drew Point USGS','Drew Point UCB')


%%
figure
aTbrw=interp1(hrAvgBRW.date, hrAvgBRW.T2m, UCBHourly.date);
plot(aTbrw, UCBHourly.airtempavg, 'k.')
axis equal
xlabel('Air Temperature at Barrow (C)')
ylabel('Air Temperature at Drew Point UCB (C)')


drewT=UCBHourly.airtempavg;

inds=find((aTbrw>0)&(drewT>0)&(abs(drewT-aTbrw)<10));

aTbrwP=aTbrw(inds);
drewTP=drewT(inds);