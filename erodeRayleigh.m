function [erodeWaterDist erodeAirDist]=erodeRayleigh(level,Hs, z)

erodeWaterDist=ones(size(z));

% try
    Hs=Hs/2;
    dz=z(2)-z(1);

    Hrms=Hs/1.416;

    waveInds=find((z<=level+2*Hs+dz)&(z>=level));

    H=z(waveInds)-level;
    
    pH=2*H.*exp(-(H./Hrms).^2)/(Hrms^2);
    pH=pH./(2*sum(pH));

    cH=cumsum(pH);

    erodeWaterDist(waveInds)=erodeWaterDist(waveInds)-(cH+0.5);

    waveInds=(z>=level+2*Hs);
    erodeWaterDist(waveInds)=0;

    waveInds=find(z<level);
    
    H=abs(z(waveInds)-level);
    pH=2*H.*exp(-(H./Hrms).^2)/(Hrms^2);
    pH=pH./(2*sum(pH));
    cH=cumsum(pH);
 
    erodeWaterDist(waveInds)=erodeWaterDist(waveInds)-flipud(cH);


% catch
%     inds=find((z<=level+2*Hs+dz));
%     erodeWaterDist=zeros(size(z));
%     erodeWaterDist(inds)=1;
% end

erodeAirDist=1-erodeWaterDist;

%plot(erodeWaterDist, z,erodeAirDist, z)
