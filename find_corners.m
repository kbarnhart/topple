function corners=find_corners(x,z, angle, dist)

%find locations where the slope of an edge (defined by x, and z) changes by
%a given sensititivity.

ang=zeros(size(x));


if size(x, 1)==1
    rightshift=[0,-1];
    leftshift=[0,1];
else
    rightshift=[-1,0];
    leftshift=[1,0];
end

xleft=circshift(x, leftshift);
xright=circshift(x, rightshift);

zleft=circshift(z, leftshift);
zright=circshift(z, rightshift);

leftside=    (((zleft- z).^2)+((xleft- x).^2)).^0.5;
rightside=   (((zright-z).^2)+((xright-x).^2)).^0.5;
oppositeside=(((zright-zleft).^2)  +((xright-xleft).^2)).^0.5;    
ang= acosd(((oppositeside.^2)-((leftside.^2+rightside.^2)))./(-2.*leftside.*rightside));  



ang=real(ang);
ang(ang==0)=180;
a=ang<=angle;
a(1)=1; % make sure that the first point is included
a(end)=1;% dtto last point
% make sure selected points aren't too close
% if to close, choose the one with the smallest angle

% need to make this section work better...
% perhaps a different format. maybe if every time a point was removed from
% v, the whole loop started over. 


v=find(a==1); %
change=1; 



while change>0
    v=find(a==1);
    
    for i=1:length(v)

        change=0; %reset change
        right=v(mod(i,length(v))+1);
        center=v(i);
        left=v(mod(i-2,length(v))+1);

        r_distan=((z(center)-z(right))^2+(x(center)-x(right))^2)^.5;
        l_distan=((z(center)-z(left))^2+(x(center)-x(left))^2)^.5;

            if r_distan<dist && l_distan<dist % if both points points are too close
              if ang(center)>ang(right)|| ang(center)>ang(left)
                  a(center)=0;
                  change=change+1;
              % delete center point. 
              end
            end
    end
      if numel(v)<5 % don't want too few points
          change=0;
      end
end

a(1)=1;
v=find(a==1); %
corners=zeros(length(v),2);

corners(:,1)=x(v);
corners(:,2)=z(v);


end
