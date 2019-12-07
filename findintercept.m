function [xi zi]=findintercept(x1a, z1a, x1b, z1b, x2a, z2a, x2b, z2b)

% make sure that intercept exists: if it does not extend points until an
% intercept does exist. 

i1=min(x1a, x1b)>max(x2a, x2b)| max(x1a, x1b)<min(x2a, x2b);
i2=min(z1a, z1b)>max(z2a, z2b)| max(z1a, z1b)<min(z2a, z2b);

if i1==1|i2==1
    % if no intercept exist, replace points, so that slopes are maintained,
    % but intercept exists. 
    % first extrapolate to zs to the x limits
    
        % interp will have issues if 
        % values of independent variable are non-distinct only
      
        xmin=min([x1a x1b x2a x2b]);
        xmax=max([x1a x1b x2a x2b]);
        zmin=min([z1a z1b z2a z2b]);
        zmax=max([z1a z1b z2a z2b]);
        
        x1=[x1a x1b];
        z1=[z1a z1b];

        x2=[x2a x2b];
        z2=[z2a z2b];
      
        if x1a~=x1b
            z1a = interp1(x1,z1,xmin,'linear','extrap');
            z1b = interp1(x1,z1,xmax,'linear','extrap');
            x1a=xmin;
            x1b=xmax;
        else
            z1a=zmin;
            z1b=zmax;
        end
        
        if x2a~=x2b
            z2a = interp1(x2,z2,xmin,'linear','extrap');
            z2b = interp1(x2,z2,xmax,'linear','extrap');
            x2a=xmin;
            x2b=xmax;
        else
            z2a=zmin;
            z2b=zmax;
        end
        
        
        

        % now extrapolate x's to z limits
        xmin=min([x1a x1b x2a x2b]);
        xmax=max([x1a x1b x2a x2b]);
        zmin=min([z1a z1b z2a z2b]);
        zmax=max([z1a z1b z2a z2b]);

        x1=[x1a x1b];
        z1=[z1a z1b];

        x2=[x2a x2b];
        z2=[z2a z2b];
        
        if z1a~=z1b
            x1a = interp1(z1,x1,zmin,'linear','extrap');
            x1b = interp1(z1,x1,zmax,'linear','extrap');
            z1a=zmin;
            z1b=zmax;
        else
             x1a=xmin;
             x1b=xmax;
        end
        
        if z2a~=z2b   
            x2a = interp1(z2,x2,zmin,'linear','extrap');
            x2b = interp1(z2,x2,zmax,'linear','extrap');
            z2a=zmin;
            z2b=zmax;
        else
            x2a=xmin;
            x2b=xmax;
        end
        
        
        
end





%make sure things are ordered from left to right
if x1a>x1b
   x1atemp=x1b;
   z1atemp=z1b;
   
   x1b=x1a;
   z1b=z1a;
   
   x1a=x1atemp;
   z1a=z1atemp;
end

if x2a>x2b
   x2atemp=x2b;
   z2atemp=z2b;
   
   x2b=x2a;
   z2b=z2a;
   
   x2a=x2atemp;
   z2a=z2atemp;
end


% make sure that if there is a difference between x1a and x2a, that dx is
% correct

if x1a~=x2a
   if x1a>x2a
      %switch pairs
      x1atemp=x2a;
      z1atemp=z2a;
      x1btemp=x2b;
      z1btemp=z2b;
      
      x2a=x1a;
      z2a=z1a;
      x2b=x1b;
      z2b=z1b;
      
      x1a=x1atemp;
      z1a=z1atemp;
      x1b=x1btemp;
      z1b=z1btemp;
     
   end
end


% find intercept

if x1a==x1b
    xi=x1a;
    zi=interp1([x2a x2b], [z2a z2b], xi, 'linear', 'extrap');
elseif x2a==x2b
    xi=x2a;
    zi=interp1([x1a x1b], [z1a z1b], xi, 'linear', 'extrap');
elseif z1a==z1b
    zi=z1a;
    xi=interp1([z2a z2b], [x2a x2b], zi, 'linear', 'extrap');
elseif z2a==z2b
    zi=z2a;
    xi=interp1([z1a z1b], [x1a x1b], zi, 'linear', 'extrap');    
else   
    dx=x2a-x1a;

    dz1dx=(z1a-z1b)/(x1a-x1b);
    dz2dx=(z2a-z2b)/(x2a-x2b);

    delx=(z1a-z2a+dx*dz1dx)/(dz2dx-dz1dx);
    
    xi=x1a+delx+dx;

    zi=z1a+(delx+dx)*dz1dx;

end
    


end