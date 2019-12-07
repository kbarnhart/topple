
close all
clear all



load all_drewpoint_data

offset=.5; % findout difference in wave logger deployment depths.

date=[wavestatWL2.date waves2010.date];
period=[wavestatWL2.waveperiod2 waves2010.tp];
depth=[wavestatWL2.waterdepth2-offset waves2010.mdepth];
wave=[wavestatWL2.hsig2 waves2010. hsig];

outl=find(wave>1.5);
date(outl)=[];
period(outl)=[];
wave(outl)=[];
depth(outl)=[];

minp=min(period);
maxp=max(period);
mind=min(depth);
maxd=max(depth);
minw=min(wave);
maxw=max(wave);

% water depth and wave height
j=linspace(minw, maxw,11);
phat=nan(2, length(j));
k=linspace(0, maxp+10, 30);

figure (1)
subplot(1,3,1)
hold on

plot(period, wave, 'r.')

hold on
for i=1:numel(j)-1
    % select range
    selind=find(wave>=j(i)&wave<=j(i+1));
    
    %make a histograpm
    %phat(:,i) = gamfit(period(selind));
    [phat(1,i) phat(2,i)]=normfit(period(selind));
    % if possible , fit a curve
    %c=gampdf(k, phat(1,i), phat(2,i));
    
    
    c=normpdf(k, phat(1,i), phat(2,i));
    plot(k, c + j(i))
end
ylabel('Significant Wave Height')
xlabel('Wave Period')
subplot(1,3,2)
plot( phat(1,:), j,'r.', phat(2,:), j, 'k.')
ylabel('Significant Wave Height')
xlabel('Statistical Paremeters')
legend('mean', 'standard deviation')

hold off

% findo out if there is a trend in the statistical parameters (mean, std, or
% a and b for gamma dist)


%% wave height and water depth
figure(2)

j=linspace(mind, maxd,6);
phat2=nan(2, length(j));
k=linspace(0, maxw+.1, 30);

figure (2)
subplot(1,2,1)
hold on

plot(wave, depth, 'ko')

for i=1:numel(j)-1
    % select range
    selind=find(depth>=j(i)&depth<=j(i+1));
    
    %make a histograpm
    phat2(:,i) = gamfit(wave(selind));
    %[phat2(1,i) phat2(2,i)]=normfit(wave(selind));
    % if possible , fit a curve
    c=gampdf(k, phat2(1,i), phat2(2,i));
    %c=normpdf(k, phat2(1,i), phat2(2,i));
    plot(k, c + j(i))
    
end
ylabel('Water Depth')
xlabel('Significant Wave Height')
subplot(1,2,2)
plot( phat2(1,:), j,'r.', phat2(2,:), j, 'k.')
ylabel('Significant Wave Height')
xlabel('Water Depth')
legend('mean', 'standard deviation')

hold off
