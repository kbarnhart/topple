function [corners]=rotateblock(corners, pivot, x,z, dir)

[a x1 z1]=findnotch(x,z);
if z1(a)>z1(end)
    a=find(x>x1(a)&z<z1(a),1,'first');
else
    a=find(x>x1(a)&z>z1(a)&z<z1(end),1,'first');
end
x=x(a:end);
z=z(a:end);

% if both pivots were the same -- resting on a point -- get rid of one of
% them.
if corners(1,1)==corners(end,1)&&corners(1,2)==corners(end,2)
   if strcmp(dir, 'left')==1
      corners(1,:)=[]; 
   else
      corners(end,:)=[];   
   end
end

%make sure that the pivot is on the topography
if strcmp(dir, 'left')==1
    corners(end,2)=interp1(x,z, corners(end,1));
    pivot=corners(end,:);
    
else
    corners(1,2)=interp1(x,z, corners(1,1));
    pivot=corners(1,:);

end
%calculate all possible rotation angles
thetas=atan((pivot(2)-corners(:,2))./(pivot(1)-corners(:,1)));

if strcmp(dir, 'right')==1
    thetas(1)=0; % first element will always be NaN
else
    thetas(end)=0;
end
%choose the rotation angle using rotation direction
if strcmp(dir, 'right')==1
    ind= thetas>0.00001&corners(:,1)>pivot(1);

    theta=thetas(ind);
    theta=min(theta);
    if numel(theta)==1
        thetaind=find(thetas==theta); 
        else
        thetaind=[];
    end
    
else
    ind= thetas<-0.00001&corners(:,1)<pivot(1);
    theta=thetas(ind);
    theta=max(theta); 
    if numel(theta)==1
    thetaind=find(thetas==theta);
    else
        thetaind=[];
    end
end

if any(thetaind)

%rotate the points
temp_corners=rotate_points(corners, theta, pivot);

% make sure all points except two are above ground

zunder=interp1(x,z, temp_corners(thetaind,1));
diftopo=temp_corners(thetaind,2)-zunder;

if diftopo~=0
    R = pyth_dist(pivot, corners(thetaind, :));
    if strcmp(dir, 'right')==1
         if diftopo>0 
            angles=-90:0; 
         else %diftopo<0
             angles=90:-1:-90;
         end
    else
        if diftopo<0 
            angles=90:180; 
        else % diftopo>0
            angles=270:-1:180;
        end
    end
    
  if any(angles)

    %calculate arc
    arcx=pivot(1)+R.*cosd(angles);
    arcz=pivot(2)+R.*sind(angles);
  else
      dum=1;
  end
    
    %find intersection  -- the polyxpoly routine works well, but is very 
    %time consumptive -- first remove extraneous arc
    
    if diftopo>0     
        % rotate down. block is above topography
        %keep only parts right around topography
        q2=find(arcz>interp1(x,z,arcx),1,'first');
        q1=find(arcz<interp1(x,z,arcx),1,'last');
        arcx=arcx(q1:q2);
        arcz=arcz(q1:q2);

    elseif diftopo<0
        %rotate up. block is below topography
        q1=find(arcz>interp1(x,z,arcx),1,'last');
        q2=find(arcz<interp1(x,z,arcx),1,'first');
        arcx=arcx(q1:q2);
        arcz=arcz(q1:q2);

    end
    
    
    [xi zi]=polyxpoly(arcx, arcz,x,z);
    
    %calculate angle
    thetarest=lawofcosines(temp_corners(thetaind,:), [xi zi], pivot, 'rad');
    if zi>interp1([pivot(1) temp_corners(thetaind,1)],[pivot(2) temp_corners(thetaind,2)], xi, 'linear', 'extrap')
       thetarest=-thetarest; 
    end
    if strcmp(dir, 'left')==1
               thetarest=-thetarest; 
    end
    
    %rotate rest of way
    temp_corners=rotate_points(temp_corners, thetarest, pivot);

    
end


corners=temp_corners;

c=find(thetas==theta);

corners(c,2)=interp1(x,z, corners(c,1));
corners(1,2)=interp1(x,z,corners(1,1));

% get rid of extra points
% do this with potentially variable topography

if strcmp(dir, 'right')==1% topple right  
    corners=circshift(corners, [-1 0]);
else
    corners=circshift(corners, [1 0]);
end

zunder=interp1(x,z, corners(:,1));
diftopo=corners(:,2)-zunder;

if strcmp(dir, 'right')==1% topple right
    under=find(abs(diftopo)<0.001,2,'first');
    corners(under(1), 2)=interp1(x,z, corners(under(1),1));
    corners(under(2), 2)=interp1(x,z, corners(under(2),1));    
else % TOPPLE LEFT
    under=find(abs(diftopo)<0.001,2,'last');
    corners(under(1), 2)=interp1(x,z, corners(under(1),1));
    corners(under(2), 2)=interp1(x,z, corners(under(2),1)); 
end
 
under2=find(abs(diftopo)<0.001);
if under2(1)~=1 || under2(2)~=numel(zunder); 
    if strcmp(dir, 'right')==1
        corners(1:under2(1)-1,:)=[];
        
        zunder=interp1(x,z, corners(:,1));
        diftopo=corners(:,2)-zunder;
        under2=find(abs(diftopo)<0.001);
        if under2(end-1)==numel(zunder)-1&&under2(end)==numel(zunder)
            corners(end,:)=[];
        end
        
        
    else %left
        corners(under2(end)+1:end,:)=[];
        
        zunder=interp1(x,z, corners(:,1));
        diftopo=corners(:,2)-zunder;
        under2=find(abs(diftopo)<0.001);
        if under2(1)==1&&under2(2)==2
            corners(1,:)=[];
        end
    end

end
else
corners=[];

end
 

