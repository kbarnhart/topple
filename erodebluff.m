function [x,z]=erodebluff(x,z, level, wave, magnitude, rest_magnitude, shelf_slope, xmax, wedge)%, shelf_slope, beach_slope, beach_length)
%under the water, right

if isnan(magnitude)
    magnitude=0;
end

if isnan(rest_magnitude)
    rest_magnitude=0;
end

if isnan(wave)
    wave=0;
end

[erodeWater erodeAir]=erodeRayleigh(level,wave, z);

if any(isnan(erodeWater))
    inds= isnan(erodeWater);
    erodeWater(inds)=0;
end

if any(isnan(erodeAir))
    inds= isnan(erodeAir);
    erodeAir(inds)=0;
end



inds=find(z<0);
erodeWater(inds)=0;
erodeAir(inds)=0;

x=x-magnitude.*erodeWater;
        
while any(x<=wedge)
    inds=find(x<=wedge);
    x(inds)=x(inds)+.1 ;
end

%rest
x=x-rest_magnitude.*erodeAir;

%extend topography to xmax
dx=abs(x(end-1)-x(end));
xadd=x(end)+dx:dx:xmax;
zadd=z(end)+shelf_slope.*(xadd - x(end));

x=[x xadd];
z=[z zadd];


end
