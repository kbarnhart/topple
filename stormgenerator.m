function [height, period, wtemp, atemp, waveheight]=stormgenerator(t, nstorms,spar)


height=zeros(size(t));


onset=ceil(numel(t)*rand(1,nstorms));
duration=ceil(spar.maxduration*rand(1,nstorms)./(t(2)-t(1)));
intensity=ceil(spar.maxintensity*rand(1,nstorms));

% % for i=1:nstorms
% %     
% %     if onset(i)+duration(i)<numel(t)
% %         height(onset(i): onset(i)+duration(i))= height(onset(i): onset(i)+duration(i))+...
% %        intensity(i).*(sin(linspace(0,pi, duration(i)+1)).^2);
% %     end
% % end


atemp=spar.M+spar.Ay.*sin((t-spar.Dy)./365.25.*2.*pi)+spar.Ad.*sin((t-spar.Dd).*2.*pi);

wtemp=spar.Mw+spar.Ayw.*sin((t-spar.D)./365.25.*2.*pi)+spar.Adw.*sin((t-spar.D).*2.*pi);


% looks like the wave heights are a function of the water depth and the
% period is a function of the wave heights. 

% use water heights to generate the wave height and then use that to
% generate the period. 

waveheight=random('gamma', spar.a, spar.b, numel(t),1);
period=random('norm', spar.Mp, spar.STp, numel(t),1);


end