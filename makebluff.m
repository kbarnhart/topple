function [xnew znew]= makebluff(deltax, xmax, bluff_edge, bluff_height, shelf_slope, beach_slope, beach_length) 
            
x=0:deltax:xmax;
a=find(x<bluff_edge);                
b=max(a)+1;
c=find(x<bluff_edge+beach_length, 1, 'last' )+1;             
                
z=zeros(size(x));
z(a)=bluff_height*ones(size(a));
                
if c<numel(x)
    z(b:c)=linspace(z(b), z(b)+(x(c)-x(b))*beach_slope, c-b+1);
    z(c:end)=linspace(z(c), z(c)+(x(end)-x(c))*shelf_slope, length(z)-c+1);                
else
    z(b:end)=linspace(z(b), z(b)+(x(end)-x(b))*beach_slope, length(z)-b+1);
end
                
xnew=0:deltax/10:xmax;
znew=interp1(x,z,xnew);

% now, get rid of all of the unnecessary points

blufftop=find(znew==bluff_height,1, 'last');

xnew(2:blufftop-1)=[];
znew(2:blufftop-1)=[];

beachend=find(xnew>bluff_edge+beach_length, 1, 'first');

xnew(beachend+10:end-1)=[];
znew(beachend+10:end-1)=[];



end