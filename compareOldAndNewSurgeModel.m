close all
clear all

load /Users/katherinebarnhart/MATLABwork/SeaIce/WaveModelNov2012
%load /Users/labuser/Documents/Katy/topple4runsJan2012/WaveModelNov2012



load /Users/katherinebarnhart/MATLABwork/fetchPaper/reconstructedDrewWaveSetup
buoy=6;

t=barrowWaves{1}.date;
t2=hourlywaves.date;



water_height=barrowWaves{1}.etas2Dc(:,buoy)-0.165-0.05;  % % mean water level relative to initial
wave_period=barrowWaves{1}.Tmdyn2Dc(:,buoy);
waveheight=barrowWaves{1}.Hmdyn2Dc(:,buoy);

water_height2=hourlywaves.etas2Dc(:,buoy)-0.165-0.05;  % % mean water level relative to initial
wave_period2=hourlywaves.Tmdyn2Dc(:,buoy);
waveheight2=hourlywaves.Hmdyn2Dc(:,buoy);


figure

ax1=subplot(3,1,1);
plot(t, water_height)
hold on
plot(t2, water_height2, 'r')
legend('Old Model', 'New Model')

ax2=subplot(3,1,2);
plot(t, wave_period)
hold on
plot(t2, wave_period2, 'r')

ax3=subplot(3,1,3);
plot(t, waveheight)
hold on
plot(t2, waveheight2, 'r')

linkaxes([ax1 ax2 ax3],'x')

datetick
