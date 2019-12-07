function [angle]=lawofcosines(A, B, C,  unit)
% where A, B, C are the coordinates of points, 
% returns angle in degrees

a=sqrt((B(1)-C(1))^2+ (B(2)-C(2))^2);
b=sqrt((A(1)-C(1))^2+ (A(2)-C(2))^2);
c=sqrt((A(1)-B(1))^2+ (A(2)-B(2))^2);

if strcmp(unit,'deg')==1
    angle=acosd((c^2-a^2-b^2)/(-2*a*b));
elseif strcmp(unit,'rad')==1
    angle=acos((c^2-a^2-b^2)/(-2*a*b));
end
end