function        [blockxr, blockzr, blockxl, blockzl,xret,zret]=...
    erode(blockxr, blockzr, blockxl, blockzl, x, z,...
    right_level, right_magnitude, left_level, left_magnitude, rest_magnitude, wave)
        

% write so that block sits on topo no mater topo slope, etc. 
%% erode sides of block.         
%under the water, right
xret=x; %store original x, z to return
zret=z;
[a x1 z1]=findnotch(x,z);
if z1(a)>z1(end)
    ind=find(x>x1(a)&z<z1(a),1,'first');
else
    ind=find(x>x1(a)&z>z1(a)&z<z1(end),1,'first');
end
x=x(ind:end);
z=z(ind:end);

if isempty(x) || isempty(z)|| isempty(blockxr) || isempty(blockxl)
    
   dum=1;
end


[erodeWaterR erodeAirR]=erodeRayleigh(right_level,wave, blockzr);
[erodeWaterL erodeAirL]=erodeRayleigh(left_level,wave, blockzl);

%right
blockxr=blockxr-right_magnitude.*erodeWaterR;
blockxr=blockxr-rest_magnitude.*erodeAirR;

%left
blockxl=blockxl+left_magnitude.*erodeWaterL;
blockxl=blockxl+rest_magnitude.*erodeAirL;
        
        
%% need to make sure that z levels coorespond on left and right sides of
% block, so that they can be compared. 

zmax=max(max(blockzr), max(blockzl));
zmin=min(min(blockzr), min(blockzl));
numelz=max(numel(blockzr), numel(blockzl));
znew=linspace(zmin, zmax, numelz);
blockxr=interp1(blockzr, blockxr, znew, 'linear','extrap');
blockxl=interp1(blockzl, blockxl, znew, 'linear','extrap');
blockzl=znew;
blockzr=znew;

%% delete portions where overlap has occuredn this could potentailly occur 
% at both the top and bottom of the block 

% with topography in x,z, this could also migrate some points "underground"    
cross=find(blockxr<blockxl);

if any(cross)    
dcross=diff(cross);



    if any(dcross>1)
        big=find(dcross>1);
        %then both top and bottom cross
        top=cross(big+1:end);
        bot=cross(1:big);
    elseif blockzr(cross(end))==blockzr(end)
        top=cross;
        bot=[];
    elseif blockzr(cross(1))==blockzr(1)
        bot=cross;
        top=[];
        
    else
        top=cross:numel(blockzr);
        bot=[];
       
    end

    if any(top)
    % top portion crosses, remove
        blockxr(top)=[];
        blockxl(top)=[];
        blockzr(top)=[];
        blockzl(top)=[];

    end
    
    if any(bot)
    % bottom portion crosses, remove, check for things under the topography
    % and make sure the bottom of the block rests on the topography
        
    
        if bot(end)>1  
            blockzr(1:bot(end-1))=[];
            blockzl(1:bot(end-1))=[];
            blockxr(1:bot(end-1))=[];
            blockxl(1:bot(end-1))=[];
        end
        a=1;
        %find intersetion of two lines
        
        [blockxr(a) blockzr(a)]=findintercept(blockxr(a), blockzr(a), blockxr(a+1), blockzr(a+1),...
                                             blockxl(a), blockzl(a), blockxl(a+1), blockzl(a+1));
           
        
        blockxl(a)=blockxr(a);
        blockzl(a)=blockzr(a);
       
        
        % shift down so that point is on ground
        zshift=blockzr(1)-interp1(x,z, blockxr(1));
        blockzr=blockzr-zshift;
        blockzl=blockzl-zshift;
       
    end
end


%% ensure that first and last points lie on the topography
% theis could mean extending one of the end points, or removing one. 
if any(blockzr)&&any(blockzl)
    
zunder=interp1(x,z, blockxr);
diftopo=blockzr-zunder;
b=find(diftopo<0);

% right
if any (b)
    %all but one points underground
    if b(end)>1
        blockzr(1:b(end)-1)=[];
        blockxr(1:b(end)-1)=[];
    end
end 

if blockzr(1)~=interp1(x,z, blockxr(1)) % new point added to extend to the surface or find intercept
    if numel(blockzr)>1
        
            %determine topography points that are close. 
            left=find(x<min(blockxr(1), blockxr(2)),1, 'last');
            right=find(x>max(blockxr(1), blockxr(2)),1, 'first');
            
            [xtemp ytemp]=findintercept(x(left), z(left), x(right), z(right), blockxr(1), blockzr(1) , blockxr(2), blockzr(2)); 
            
            if any(xtemp) 

                blockxr(1)=xtemp;
                blockzr(1)=ytemp;
            else
                blockxr=[];
                blockzr=[];
            end
    else
        blockxr=[];
        blockzr=[];
        
    end
end


zunder=interp1(x,z, blockxl);
diftopo=blockzl-zunder;
b=find(diftopo<0);

%left
if any(b)
    %remove all but 1 points underground
    if b(end)>1
        blockzl(1: b(end)-1)=[];
        blockxl(1: b(end)-1)=[];
    end
end 



if blockzl(1)~=interp1(x,z, blockxl(1)) % new point added to extend to the surface or find intercept
    if numel(blockzl)>1
        
        %determine topography points that are close. 
        left=find(x<min(blockxl(1), blockxl(2)),1, 'last');
        right=find(x>max(blockxl(1), blockxl(2)),1, 'first');
        
        [xtemp ytemp]=findintercept(x(left), z(left), x(right), z(right), blockxl(1), blockzl(1) , blockxl(2), blockzl(2));
        if any(xtemp) 
        
            blockxl(1)=xtemp;
            blockzl(1)=ytemp;
        else
            blockxl=[];
            blockzl=[];
        end
    else
        blockxl=[];
        blockzl=[];
    end
    
end

end


end
        
        
        
    
 

        
     
       