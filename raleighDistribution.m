% raleigh distribution
close all
clear all
Hs=1;


Hrms=Hs/1.416;
H = [0:0.1:10];
pH=2*H.*exp(-(H./Hrms).^2)/(Hrms^2);
plot(H, pH)
hold on
plot([Hs Hs], [0 1], 'r')
plot([2*Hs 2*Hs], [0 1], 'r')

cP=cumsum(pH./sum(pH));

figure
plot(cP, H)

z=0:0.01:10;
level=6;
Hs=3;

[erodeWater erodeAir]=erodeRayleigh(level,Hs, z);

figure
plot(erodeWater, z)%,erodeAir, z)
hold on

plot([0 1], [level-Hs/2 level-Hs/2])
plot([0 1], [level+Hs/2 level+Hs/2])




