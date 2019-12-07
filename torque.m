function [T]=torque(corners,pivot)
corners(:,1)=corners(:,1)-pivot(1);
corners(:,2)=corners(:,2)-pivot(2);

%must be a closed loop
if corners(end,1)~=corners(1,1)&&corners(end,2)~=corners(1,2)
corners=[corners; corners(1,:)];
end

if numel(corners(:,1))==1
T=0;
else
T=trapz(corners(:,1).*corners(:,1), corners(:,2));
end


end