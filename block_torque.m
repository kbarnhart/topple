function [T H Lxp xp corners a x] =block_torque(xorig, zorig, ice_wedge)

            [a x z]=findnotchBluff(xorig,zorig);
            pivot(1)=x(a);
            pivot(2)=z(a);
            
            % corners
            b=find(x>ice_wedge, 1,'first');
            
            corners(:,1)=x(b:a);
            corners(:,2)=z(b:a);
             
            temp1=[ice_wedge z(b(1))];
            temp2=[ice_wedge z(a)];
            temp3=[x(a), z(a)];
       
            
            corners=flipud(vertcat(temp3, temp2, temp1, corners));

            % calculate torque:
            T=torque(corners,pivot);
            H=z(b(1))-z(a);
            Lxp=ice_wedge;
            xp=x(a);
            a=1;
            x=corners(:,1);
end