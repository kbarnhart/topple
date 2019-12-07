function [corners, zright, zleft, xright, xleft]= make_block (corners, vnum)

a=find(corners(:,2)==max(corners(:,2)));



if numel(a)==1

    right_block=corners(1:a,:);
    left_block=flipud(corners(a:end,:));
    
else
   
    right_block=corners(1:a(1),:);
    left_block=flipud(corners(a(end):end,:));
   
    
end
% occasionally there will be a point below another each side should be
% monotonically increaseing for the interp to work. 

if size(left_block, 1)>1
    a=find(left_block(1:end-1,2)>left_block(2:end,2));
    
        while ~isempty(a)
            left_block(a+1,2)=left_block(a+1,2)+0.001;
            a=find(left_block(1:end-1,2)>left_block(2:end,2));

        end
    
end

if size(right_block, 1)>1
    a=find(right_block(1:end-1,2)>right_block(2:end,2));
    while ~isempty(a)
        right_block(a+1,2)=right_block(a+1,2)+0.001;
        a=find(right_block(1:end-1,2)>right_block(2:end,2));

    end
end
%sometimes this may need to be redefined
zminr =min(right_block(:,2));
zminl=min(left_block(:,2));
zmax=max([right_block(:,2);left_block(:,2)]);

zright=linspace(zminr,zmax,vnum);
zleft=linspace(zminl, zmax, vnum);

xright=interp1(right_block(:,2),right_block(:,1), zright);
xleft=interp1(left_block(:,2),left_block(:,1), zleft);





end