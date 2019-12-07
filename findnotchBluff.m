function [a xblock zblock]=findnotchBluff(x,z)
            angle=178;
            dist=0.1;
           
            bluff_corners=find_corners(x,z,angle, dist);
          
            bluffEdgeX=bluff_corners(2,1);
            
            x=bluff_corners(:,1);
            z=bluff_corners(:,2);
            
            xblock=x;
            zblock=z;
            
            a=find(z<=0.05,1,'first');
            
% %             
% %             dz=diff(z)./diff(x);
% %             ddz=diff(dz)./diff(diff(x));
% %            
% %             %remove the first two and last two points
% %             
% %             x(1:2)=[];
% %             x(end-1:end)=[];
% %             z(1:2)=[];
% %             z(end-1:end)=[];
% %             ddz(1)=[];
% %             ddz(end)=[];
% %             
% %           
% %             if numel(ddz)==1;
% %                 a=3;
% %                 
% %                 
% %             else
% %                 a=find((ddz<0)&(x<bluffEdgeX+0.2),1, 'last')+2;
% %                 if isempty(a)
% %                    a=numel(ddz)+2; 
% %                    a=3;
% %                 end
% %             end
% %               % pivot          
% %             
% %             % the last 
            
            
        
end       