function [xr, zr, xl, zl]= splitlr(x, z)

top=find(z==max(z));

if numel(top)~=1
    delete=top(2:end-1);
    x(delete)=[];
    z(delete)=[];
    
    top(2:end-1)=[];
    
 
    
    % create new left and right vectors
    xl=x(1:top(1));
    zl=z(1:top(1));
        
    xr=x(top(2):end);
    zr=z(top(2):end);
    
else

     xl=x(1:top);
     zl=z(1:top);
     xr=x(top:end);
     zr=z(top:end);
    
end
end