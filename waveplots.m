%wave plots
close all
clear all
load all_drewpoint_data

% wavestatWL2
% waves2010
figure(1)

plot(wavestatWL2.hsig2, wavestatWL2.waterdepth2, 'k.')
hold on
plot(waves2010.hsig, waves2010.mdepth, 'r*')
axis equal

legend('2009', '2010')
xlabel('Significant Wave Height [m]')
ylabel('Water Depth [m]')
hold off


figure(2)

plot(wavestatWL2.date, wavestatWL2.waterdepth2, 'k')
hold on
plot(waves2010.date, waves2010.hsig, 'r')
plot(levellogger.date, levellogger.depth, 'b')
datetick
legend('2009 Wave Logger', '2010 Wave Logger', '2010 Levellogger')

figure(3)

subplot(1,2,1)
hold on
plot(wavestatWL2.hsig2, wavestatWL2.waveperiod2, 'k.')
plot(waves2010.hsig, waves2010.tp, 'r*')
xlabel('Significant Wave Height [m]')
ylabel('Wave Period [s]')
hold off


subplot(1,2,2)
hold on
plot(wavestatWL2.waterdepth2, wavestatWL2.waveperiod2, 'k.')
plot(waves2010.mdepth, waves2010.tp, 'r*')
legend('2009', '2010')
xlabel('Water Depth [m]')
ylabel('Wave Period [s]')
hold off


figure(4)

hist(wavestatWL2.waterdepth2, 10)
hold on
hist(waves2010.mdepth, 10)