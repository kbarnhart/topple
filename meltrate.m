function [Mwater Mair]=meltrate(depth,waveHeight, water_temp, wave_period, air_temp, subair_coeff, plcoeff, method,beta_coeff)

deltaW=-1.8; %C %FROM RUSSELL-HEAD 1980 melting of salt water

if strcmp(method, 'rh')==1
    % parameters for m/day erosion of iceberg in sea water
    alpha=1.8e-2; %FROM RUSSELL-HEAD 1980
    beta=1.5; %FROM RUSSELL-HEAD 1980
    Mwater=(alpha).*(water_temp-deltaW).^beta; %melt rate in m/day from Russell-Head
    Mwater=Mwater/(60*60*24); % convert to M/s for comparison with White
    Mwater=Mwater.*beta_coeff;
elseif strcmp(method, 'white')==1
    %from kubat(2007)eq.11 after white 1980.  roughness ht R=10mm = 0.01m
    roughness = 0.01;
    Mwater = 0.000146.*(water_temp-deltaW).*(roughness.^0.2).*(waveHeight.^0.8)./wave_period; %melt rate in m/s
    Mwater=Mwater.*beta_coeff;
 
elseif strcmp(method, 'kob/ravens')==1;
    load zetaForW65.mat


    g=(9.81); % m/s2
    dstar=1; % characteristic depth; This is the depth used for the block. 

    zetam=interp1(zetaForW65.T, zetaForW65.zeta, water_temp);
 
    depth=waveHeight;
    
    epsilon=0.4.*(depth).*sqrt(g.*(depth));

    Mwater=(2*(zetam.^2).*epsilon)./dstar; % in m/s
    Mwater=Mwater.*beta_coeff;
        
    
end

Mair=subair_coeff*air_temp; % subaerial melt rate in m/day

