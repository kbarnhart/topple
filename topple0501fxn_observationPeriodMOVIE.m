function topple0501fxn_observationPeriodMOVIE(outPath, t, dt, iceon, water_height, wave, m, m_air, meth)


mOut='/Users/katherinebarnhart/Desktop/MANUSCRIPTS/Northslope Coastal Erosion/exampleMovie';
writerObj = VideoWriter(mOut);
writerObj.FrameRate=40;
writerObj.Quality=100;
open(writerObj);



%% Sensitivity Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these will controll how sensitive the block corner finding and block
% rebuilding functions are. 

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
xmax=100;               % meters            % total length of model space
b_initial=80;          % meters            % initial bluff edge location
dx=0.1;                 % meters            % x direction spacing
b_height=4;             % meters            % bluff height
beach_length=10;        % meters            % length of "beach"
beach_slope=-0.08;      % meters/meters     % slope of beach
shelf_slope=-0.001;     % meters/meters     % slope of shelf

%%%%%%%%%%%%%%%%%%%%%%% ice wedges %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nwedge=100;              % integer           % number of ice wedges
ice_depth=4;            % meters            % depth of ice wedges


%% load inputs
% load ice wedge spacing
ice_wedge = b_initial -cumsum(icewedgespacing(nwedge));
j=1;

ice_wedge(1)=67;
wedge=ice_wedge(j);

%% adjust melt rates

m(m<0)=0;
m_air(m_air<0)=0;

% negwave=water_height<=0;
% m(negwave)=0;


water_height(water_height>3.9)=3.9;

%% create initial conditions
[x z]= makebluff(dx, xmax, b_initial, b_height, shelf_slope, beach_slope, beach_length);

% create block.
block=1;
firstBlock=1;

bluffoffs=0.6+1;
water_height=water_height+(beach_slope)*(bluffoffs-0.6);

firstblockx=[b_initial+bluffoffs+4, b_initial+bluffoffs+3.25,b_initial+bluffoffs+1.75, b_initial+bluffoffs];
firstblockz=[interp1(x,z,firstblockx(1), 'linear', 'extrap'),3.5,3.5, interp1(x,z,firstblockx(end), 'linear', 'extrap')];
corners=zeros(length(firstblockx),2);

corners(:,1)=firstblockx;
corners(:,2)=firstblockz;
[corners, blockzr, blockzl, blockxr, blockxl]= make_block (corners, vnum);
[blockx blockz]=puttogether(blockxl, blockxr, blockzl, blockzr);



%% create vectors to save topography
topofbluff=zeros(size(m));
notch=zeros(size(m));
blockrec=zeros(size(m));
blockArea=zeros(size(m));
notchdepth=zeros(size(m));
bluffLoc=zeros(size(m));


%% run
for i=1:length(m)
    
    if firstBlock==1; % we only care about the demise of block #1
    
    if iceon(i)==1
        if strcmp(meth, 'kob/ravens')==1
            if i>1
                kobDstarFactor=1/max(notchdepth(i-1), 0.5);
              
                mbluff=m(i)*kobDstarFactor;
            else
                mbluff=m(i);
            end
        else
            mbluff=m(i);
            
        end
    % if block is present
    if block==1
        if numel(blockxr)>2 && numel(blockxl)>2
            blockrec(i)=1; % save presence of a block
            % erode block   
        
            toErode=m(i)*dt;
            erodeAmtMax=0.01;
            
            while toErode>0
                % erode only 1 cm at a time (for stability)
                if toErode>erodeAmtMax
                    erodeAmt=erodeAmtMax;
                    
                else
                    erodeAmt=toErode;         
                end
                airAmt=m_air(i)*dt/(toErode/erodeAmt);
                
                try
                    [blockxr, blockzr, blockxl, blockzl, x, z]=erode(blockxr, blockzr, blockxl, blockzl, x, z, water_height(i), erodeAmt, water_height(i), erodeAmt*0.3, airAmt, wave(i));
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
    
    if block==0
        firstBlock=0;
        firstBlock=1;
    end
    
    end

     
 
    % erode bluff
    toErode=mbluff*dt*0.25;
    erodeAmtMax=0.01;
    
    while toErode>0        
        if toErode>erodeAmtMax
            erodeAmt=erodeAmtMax;
        else
            erodeAmt=toErode;         
        end
        
        airAmt=m_air(i)*dt/(toErode/erodeAmt); 
        
        try   
            [x,z]=erodebluff(x,z, water_height(i)*0.5,wave(i), erodeAmt, airAmt, shelf_slope, xmax, wedge);% beach_slope, beach_length);   
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
            firstBlock=0;
            %create new bluff, move ice wedge
            [x z]= makebluff(dx, xmax, wedge, b_height, shelf_slope, beach_slope, beach_length);

            j=j+1;
            wedge=ice_wedge(j);  
            %rotate block, make block

            corners=rotateblock(bluff_corners, bluff_corners(1,:), x,z,'right');
            if numel(corners)>6
                [corners, blockzr, blockzl, blockxr, blockxl]= make_block (corners, vnum);
            else
                block=0;
            end
            toErode=0;
        end
        
        toErode=toErode-erodeAmt;
    end
   
     % save parameters
    topofbluff(i)=b_initial-xcorn(2);
    notch(i)=b_initial-xcorn(a);
    notchdepth(i)=topofbluff(i)-notch(i);
    bluffLoc(i)=b_initial-x(find(z<b_height,1,'first'));

    
    

    % end
    
% % % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if firstBlock~=0;

    
    %     Interior Plotting Routine
        figure(1);
        clf
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperUnits', 'inches');

     
        set(gcf, 'PaperPosition', [2 2  16 12]);
        set(gcf, 'Units', 'inches', 'OuterPosition',[2 2 16 12]);
    
    subplot(2,1,1)
            set(gca,'FontSize',16)

    plot(x,z, 'k')%, blockxr,blockzr, blockxl, blockzl)
    hold on
    plot([wedge wedge], [0 b_height], 'r')
    
    indWater=find(z<water_height(i),1,'first');
    indWaveBluff=find(z<water_height(i)+wave(i)/2,1,'first');
    indWaveBluff2=find(z<water_height(i)-wave(i)/2,1,'first');


    xWaterBluff=x(indWater);
    xWaveBluff=x(indWaveBluff);
    xWaveBluff2=x(indWaveBluff2);

    if block==1;
        plot([blockxl fliplr(blockxr)],[blockzl fliplr(blockzr)], 'k')
         
        indWater=find(blockzr>water_height(i),1,'first');   
        xWaterBlock=blockxr(indWater);
        indWave=find(blockzr>water_height(i)+wave(i)/2,1,'first');
        xWave=blockxr(indWave);
        
        indWave2=find(blockzr>water_height(i)-wave(i)/2,1,'first');
        xWave2=blockxr(indWave2);
        

    
%     plot(bluff_corners(:,1), bluff_corners(:,2), 'r.')
% 	plot(bluff_corners(a,1), bluff_corners(a,2), 'y^')
    
    plot([max(xWaterBlock, xWaterBluff) 100],[water_height(i) water_height(i)], 'k')
    plot([max(xWave2, xWaveBluff2) 100],[water_height(i)-wave(i)/2 water_height(i)-wave(i)/2], 'b')
    plot([max(xWave, xWaveBluff) 100],[water_height(i)+wave(i)/2 water_height(i)+wave(i)/2], 'b')

       %plot([xWaveBluff 100],[water_height(i) water_height(i)], 'b')
    
    if water_height(i)>min(blockzl)
        
        indWater=find(blockzl>water_height(i),1,'first');   
        xWaterBlockLeft=blockxl(indWater);
        plot([xWaterBluff xWaterBlockLeft],[water_height(i) water_height(i)], 'k')
        
        
        indWater=find(blockzl>water_height(i)+wave(i)/2,1,'first');   
        xWaterBlockLeft=blockxl(indWater);
        plot([xWaveBluff xWaterBlockLeft],[water_height(i)+wave(i)/2 water_height(i)+wave(i)/2], 'b')
        
        indWater2=find(blockzl>water_height(i)-wave(i)/2,1,'first');   
        xWaterBlockLeft=blockxl(indWater2);
        plot([xWaveBluff2 xWaterBlockLeft],[water_height(i)-wave(i)/2 water_height(i)-wave(i)/2], 'b')
        
        
         
     end
%     
    else
%        plot([xWaterBluff 100],[water_height(i) water_height(i)], 'b')
%        xWaveBluff=z(indWaveBluff);
%        plot([xWaveBluff 100],[water_height(i) water_height(i)], 'b')

    end
   
    axis equal
    axis([65    95 -2 5])
   
    text(0.75,0.10, ['Time: ' datestr(t(i), 'mm/dd/yyyy HH:MM')],'Units', 'normalized','FontSize',16) 
    text(75,3.5, 'Bluff Profile','FontSize',12) 
    text(82.5,4, 'Toppled Block','FontSize',12) 
    text(66.5,0, 'Ice Wedge', 'Rotation', 90,'FontSize',12) 
    xlabel('Model Domain [m] (no vertical exaggeration)','FontSize',18)
    drawnow
    hold off
    
    
    subplot(2,1,2)
            set(gca,'FontSize',16)

    plot(t, water_height, 'k')
    hold on
    plot(t, water_height+wave./2, 'b')
    plot(t, water_height-wave./2, 'b')

    plot(t(i), water_height(i), 'ko', 'MarkerSize', 12', 'MarkerFaceColor', 'y', 'MarkerEdgeColor','k')
    plot(t(i), water_height(i)+wave(i)/2, 'ko', 'MarkerSize', 8', 'MarkerFaceColor', 'r', 'MarkerEdgeColor','k')
    plot(t(i), water_height(i)-wave(i)/2, 'ko', 'MarkerSize', 8', 'MarkerFaceColor', 'r', 'MarkerEdgeColor','k')

    datetick
    xlabel('Date','FontSize',18)
    ylabel('Water Level (set up + wave height) [m]','FontSize',18)
    legend('Set Up', '+/- Wave Height')
    
    
    
     f=figure(1);

     frame= getframe(f);
     writeVideo(writerObj,frame);
    
end
     % % % % 
% % % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    else
        if i==1
            blockrec(i)=0;
            topofbluff(i)=b_initial;
            notch(i)=b_initial;
            notchdepth(i)=bluffLoc(i)-notch(i);
            bluffLoc(i)=b_initial-x(find(z<b_height,1,'first'));

        else
            blockrec(i)=blockrec(i-1);
            topofbluff(i)=topofbluff(i-1);
            notch(i)=notch(i-1);
            notchdepth(i)=notchdepth(i-1);
            bluffLoc(i)=bluffLoc(i-1);
        end

    end

        


    
    end
    
    if rem (i, 500)==0
       fprintf([ num2str(i) ' iterations of ' num2str(numel(m)) '\n'] ) 
       fprintf([ num2str(toc) ' seconds elapsed \n \n'] ) 
    end
    
    
end
t=t';

close(writerObj);


end

%% finalize
%Draw Figures