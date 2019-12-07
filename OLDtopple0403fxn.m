function topple0403fxn(outPath, t, dt, iceon, water_height, m, m_air, method)
%% Sensitivity Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these will controll how sensitive the block corner finding and block
% rebuilding functions are. 
tic

dist=0.01;              % meters            % minimum distance between corners
angle=178;              % degrees           % maximum corner angle
vnum=100;               % integer           % number of elements in block side vectors

%% Synching Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% used to set how all of the timeseries are synched. 
timetype='min';         % string            % Size of Timestep to use
                                            % 'max'
                                            % 'min', defaut
                                            
cuttype='cut';          % string            % Cut the timeseries to where they overlap? 
                                            % 'full'
                                            % 'cut'

interptype='spline';    % string            %interptype options-- same as for the function interp1 (below is copied
                                            % from the help documentation
                                            % 'nearest' -- Nearest neighbor
                                            % interpolation
                                            % 'linear'-- Linear interpolation (default)
                                            % 'spline'-- Cubic spline interpolation
                                            % 'pchip'-- Piecewise cubic Hermite interpolation 
                                            % 'cubic'--(Same as 'pchip') 
                                            % 'v5cubic'-- Cubic interpolation used in MATL
                                            
%% Model Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load matprop
%%%%%%%%%%%%%%%%%%%%%%% geometry of model space %%%%%%%%%%%%%%%%%%%%%%%%%%%
xmax=40000;               % meters            % total length of model space
b_initial=39980;          % meters            % initial bluff edge location
dx=0.05;                 % meters            % x direction spacing
b_height=4;             % meters            % bluff height
beach_length=10;        % meters            % length of "beach"
beach_slope=-0.05;      % meters/meters     % slope of beach
shelf_slope=-0.001;     % meters/meters     % slope of shelf

%%%%%%%%%%%%%%%%%%%%%%% ice wedges %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nwedge=1000;              % integer           % number of ice wedges
ice_depth=4;            % meters            % depth of ice wedges


%% load inputs
% load ice wedge spacing
load icewedgesApril2013 % this puts all the ice wedges in the same place for all model runs. Which makes things comparable...
%wedges=icewedgespacing(nwedge);

ice_wedge = b_initial-cumsum(wedges);
j=1;
wedge=ice_wedge(j);

%% adjust melt rates

m(m<0)=0;
m_air(m_air<0)=0;

% % negwave=water_height<=0;
% % m(negwave)=0;


water_height(water_height>3.9)=3.9;

%% create initial conditions
[x z]= makebluff(dx, xmax, b_initial, b_height, shelf_slope, beach_slope, beach_length);
block=0;

%% create vectors to save topography
topofbluff=zeros(size(m));
notch=zeros(size(m));
blockrec=zeros(size(m));
notchdepth=zeros(size(m));
bluffLoc=zeros(size(m));
%% run
erodeAmtMax=0.1;

lastTime=toc;
m(isnan(m))=0;
m(m<0)=0;

for i=1:length(m)
if iceon(i)==1
    if water_height(i)>0.1
        dum=1;
    end
        
    % if block is present
    if block==1
        if numel(blockxr)>2 && numel(blockxl)>2
            blockrec(i)=1; % save presence of a block
            % erode block   
        
            toErode=m(i)*dt;
            
            while toErode>0
                % erode only 1 cm at a time (for stability)
                if toErode>erodeAmtMax
                    erodeAmt=erodeAmtMax;
                    
                else
                    erodeAmt=toErode;         
                end
                airAmt=m_air(i)*dt/(toErode/erodeAmt);
                
                try
                    [blockxr, blockzr, blockxl, blockzl, x, z]=erode(blockxr, blockzr, blockxl, blockzl, x, z, water_height(i), erodeAmt, water_height(i)*0.3, erodeAmt, airAmt);
                catch
                end

                    if numel(blockxr)>2 && numel(blockxl)>2

                        %put block back together

                        [blockx blockz]=puttogether(blockxl, blockxr, blockzl, blockzr);

                        blockArea(i)=abs(trapz(blockx,blockz));

                        % define pivot points
                        pivotr=[blockx(1) blockz(1)];
                        pivotl=[blockx(end) blockz(end)];
                        % find corners


                        corners=find_corners(blockx,blockz, angle,dist);

                        % if block exists, evaluate block stability

                        if numel(corners)>=4

                            torquer=torque(corners,pivotr);
                            torquel=torque(corners,pivotl);

                            % if block is unstable

                            if torquer==0 || torquel==0
                                block=0;
                            end

                            while torquel>0||torquer<0
                                try
                                    if torquel>0
                                        [corners]=rotateblock(corners, pivotl, x,z, 'left');
                                    elseif torquer<0 
                                        [corners]=rotateblock(corners,pivotr, x,z, 'right');    
                                    end

                                    if any(corners)
                                        % redefine pivot points
                                        pivotr=corners(1,:);
                                        pivotl=corners(end,:);
                                        %re evaluate stability
                                        torquer=torque(corners,pivotr);
                                        torquel=torque(corners,pivotl);

                                        if torquer==0|| torquel==0
                                            block=0;
                                        else
                                        [corners, blockzr, blockzl, blockxr, blockxl]= make_block (corners, vnum);
                                             if abs(trapz(corners(:,1), corners(:,2)))<1
                                                block=0;
                                                blockzr=[]; blockzl=[]; blockxr=[]; blockxl=[]; blockx=[]; blockz=[];
                                            end
                                        end
                                    else
                                        block=0;

                                        torquel=0;
                                        torquer=0;

                                    end
                                catch
                                   block=0 ;
                                   torquel=0;
                                   torquer=0;

                                end




                            end

                        else
                            block=0;
                        end

                    else
                        block=0;
                    end 
                    toErode=toErode-erodeAmt;
            end
        
        else
            block=0;
        end
     
    end

    % erode bluff
    if strcmp(method, 'kob/ravens')==1
        if i>1
            kobDstarFactor=1/max(notchdepth(i-1), 0.1);
            mbluff=m(i)*kobDstarFactor;
        else
            mbluff=m(i);
        end
    else
    	mbluff=m(i);
            
    end 
        
    toErode=mbluff*dt;
    notchDepth=0.1;
    eroded=0;
    
    [tq H Lxp xp bluff_corners a xcorn]=block_torque(x, z, wedge);
    
    while toErode>0

        [tq H Lxp xp bluff_corners a xcorn]=block_torque(x, z, wedge);

 
        if toErode>erodeAmtMax
            erodeAmt=erodeAmtMax;
        else
            erodeAmt=toErode;         
        end
        airAmt=m_air(i)*dt/(toErode/erodeAmt); 

    
        try
            [x,z]=erodebluff(x,z, water_height(i), erodeAmt,airAmt, shelf_slope, xmax, wedge);% beach_slope, beach_length);   
        catch
        end
        
    
    
    % evaluate bluff stability
    
    [tq H Lxp xp bluff_corners a xcorn]=block_torque(x, z, wedge);
 
    
    T=rho*g*tq+... %torque on rigid block
        tauice*H*(Lxp-xp)+... % vertical ice wedge resistance
        taupf*(Lxp^2/2-xp*Lxp+xp^2/2); % horizontal permafrost resistance
        % see your black book notes on the derrivation  
    

    if T<0 || xcorn(a)<=wedge+.1 % if bluff is unstable
        block=1; 
     
        %create new bluff, move ice wedge
        [x z]= makebluff(dx, xmax, wedge, b_height, shelf_slope, beach_slope, beach_length);
        newBluffEdge=wedge;
        j=j+1;
        wedge=ice_wedge(j);
        
        %rotate block, make block
       
        try
            corners=rotateblock(bluff_corners, bluff_corners(1,:), x,z,'right');
            if numel(corners)>6
                [corners, blockzr, blockzl, blockxr, blockxl]= make_block (corners, vnum);
            else
                block=0;
            end
        catch
            % make a basic block...
            firstblockx=[newBluffEdge+0.6+4, newBluffEdge+0.6+3.25,newBluffEdge+0.6+1.75, newBluffEdge+0.6];
            firstblockz=[interp1(x,z,firstblockx(1), 'linear', 'extrap'),3.5,3.5, interp1(x,z,firstblockx(end), 'linear', 'extrap')];
            
            corners=zeros(length(firstblockx),2);

            corners(:,1)=firstblockx;
            corners(:,2)=firstblockz;
            
            [corners, blockzr, blockzl, blockxr, blockxl]= make_block (corners, vnum);
            [blockx blockz]=puttogether(blockxl, blockxr, blockzl, blockzr);
        end


    end
    
    notchDepth=abs(x(find(z<b_height-0.1,1,'first'))-xcorn(a));
    
    % recalculate KOB
    eroded=eroded+erodeAmt;
    
    if strcmp(method, 'kob/ravens')==1
        if i>1
            kobDstarFactor=1/max(notchDepth, 0.1);
            mbluff=m(i)*kobDstarFactor;
        else
            mbluff=m(i);
        end
    else
    	mbluff=m(i);
            
    end 
        
    toErode=(mbluff*dt)-eroded;
    
    end
    
    % save parameters
    bluffLoc(i)=b_initial-x(find(z<b_height-0.01,1,'first'));
    topofbluff(i)=b_initial-x(find(z<b_height-0.01,1,'first'));% b_initial-xcorn(2);
    notch(i)=b_initial-xcorn(a);
    notchdepth(i)=notchDepth;
    
    
    
 
% end


% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %%% Interior Plotting Routine
% % % % plot(x,z,'g')%, blockxr,blockzr, blockxl, blockzl)
% % % % hold on
% % % % 
% % % % plot(x,z,'g.')%, blockxr,blockzr, blockxl, blockzl)
% % % % 
% % % % plot([wedge wedge], [0 b_height], 'r')
% % % % if block==1;
% % % %     plot(blockxr,blockzr, blockxl, blockzl)
% % % % end
% % % % plot(bluff_corners(:,1), bluff_corners(:,2), 'r.')
% % % % plot(bluff_corners(a,1), bluff_corners(a,2), 'y^')
% % % % plot([xcorn(a) xcorn(a)], [-1 b_height+1], 'k')
% % % % plot([x(find(z<b_height-0.01,1,'first')) x(find(z<b_height-0.01,1,'first'))], [-1 b_height+1], 'm')
% % % % 
% % % % 
% % % % 
% % % % plot([xcorn(2)-50 xcorn(2)+20],[water_height(i) water_height(i)], 'b')
% % % % 
% % % % text(0.85,0.15, datestr(t(i)),'Units', 'normalized') 
% % % % 
% % % % axis equal
% % % % axis([xcorn(2)-20 xcorn(2)+20 -10 10])
% % % % drawnow
% % % % hold off
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


else
    
    % for when sea ice is present
    if i==1
        blockrec(i)=0;
        topofbluff(i)=b_initial-b_initial;
        notch(i)=b_initial-b_initial;
        bluffLoc(i)=b_initial-b_initial;
        notchdepth(i)=bluffLoc(i)-notch(i);
    else
        bluffLoc(i)=bluffLoc(i-1);
        blockrec(i)=blockrec(i-1);
        topofbluff(i)=topofbluff(i-1);
        notch(i)=notch(i-1);
        notchdepth(i)=notchdepth(i-1);
    end

end
% output=[tstart+i*dt, notch(i), topofbluff(i), m(i), m_air(i),  water_height(i), wave_period(i), water_temp(i), air_temp(i)];
% dlmwrite(outPath, output,'-append');    
if rem (i, 20000)==0
       time=toc;
    
       
       fprintf([ num2str(i) ' iterations of ' num2str(numel(m)) '\n'] ) 
       fprintf([ num2str(toc) ' seconds elapsed \n \n'] ) 
       
       t=t';

       save(outPath, 't', 'notch', 'topofbluff', 'm', 'm_air', 'water_height', 'blockrec','bluffLoc','notchdepth')
  
%        if time-lastTime>45
%            variableThatDNE==variableNumber2;
%        end
%        lastTime=time;
           
end

end
t=t';

save(outPath, 't', 'notch', 'topofbluff', 'm', 'm_air', 'water_height', 'blockrec','bluffLoc','notchdepth')
end
%% finalize
%Draw Figures