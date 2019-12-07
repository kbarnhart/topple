function [a x z]=findnotch(x,z)
            angle=178;
            dist=0.1;
           
            bluff_corners=find_corners(x,z,angle, dist);
          
            
            x=bluff_corners(:,1);
            z=bluff_corners(:,2);
            
            
            x=bluff_corners(:,1);
            z=bluff_corners(:,2);
            
            xblock=x;
            zblock=z;
            
            %a=find(z<=0.1,1,'first');

	    a=find((z<=0.1)&(z>=0),1,'last');
% % %             
% % %             dz=diff(z)./diff(x);
% % %             ddz=diff(dz)./diff(diff(x));
% % %            
% % %             % pivot          
% % %             a=find(ddz<0)+2;
% % %             
% % %         
% % %             
% % %             if isempty(a)
% % %                 a=find(z==0,1,'first');
% % %                 if isempty(a)
% % %                     a=find(z<0.00001,1,'first');
% % %                 end
% % %                 
% % %             else
% % %               
% % % 
% % %                 a=a(1); 
% % %                 
% % %             end
% % %             
% % %             if a==numel(x)
% % %                 a=find(z==0,1,'first');
% % %                 if isempty(a)
% % %                     a=find(z<0.00001,1,'first');
% % %                 end
% % %             end
% % %             
% % %             
end       