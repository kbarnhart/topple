close all
clear all
tic

mainFolder=cd;
experimentFolder='paperFullRun01';

if ~exist(experimentFolder, 'dir')
    mkdir(experimentFolder)
end

whiteFN='whMethod';
rhFN='rhMethod';
krFN='krMethod';
plFN='plMethod';

subMarineModel={whiteFN, rhFN, krFN};%, plFN};

full='full';
half='half';
doub='doub';
four='four';
quad='quad';

waveChange={half, doub, four};
levelChange={half, doub, four, quad};
beachChange=[-0.3:0.05:0.3];

beachStr={'n30', 'n25', 'n20','n15','n10', 'n05','00','p05','p10','p15','p20', 'p25', 'p30'};
%beachStr={'n10','n09','n08', 'n07','n06','n05','n04', 'n03','n02','n01','00','p01', 'p02','p03','p04','p05','p06','p07', 'p08','p09','p10'};

if ~exist(experimentFolder, 'dir')
    mkdir(experimentFolder)
end

tOffset=-5:1:5;
tOffsetStr={'n5','n4','n3', 'n2','n1','00','p1','p2','p3','p4','p5'};

%%
load WaveModelNov2012
%load /Users/labuser/Documents/Katy/topple4runsJan2012/WaveModelNov2012

load reconstructedDrewWaveSetup
buoy=6;

t=barrowWaves{1}.date;
t2=hourlywaves.date;

tstart=min(barrowWaves{1}.date);
tend=max(barrowWaves{1}.date);
dt=1/24;

tmodel=tstart:dt:tend;

%t=tstart:dt:tend;
numit=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % observed sea ice
obsiceon=seaiceprep(t);

% futureiceon=futureseaice(tstart, tend, dt);
    
%%%%%%%%%%%%%%%%%%%%%%% permafrost characteristics %%%%%%%%%%%%%%%%%%%%%%%%
              % degrees C         % temperature difference between permafrost and zero
W=0.65;                 % fraction          % ice content

%%%%%%%%%%%%%%%%%%%%%%% melt rate calculation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
method='white';         % string            % method for determining melt rate as a function of environment
                                            % 'white'= white/kubat 
                                            % 'rh'= russel head 
subair_coeff=0.005; % m/(degC day)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load matprop
%calculate bulk properties of permafrost based on ice fraction
kbulk=(kso^(1-W))*(ki^W);
cbulk=(cso*(1-W))+(ci*W);
rhobulk=(rhoso*(1-W))+(rhoi*W);

% zeta_kobayashi=((beta_kob*W*rhoi*L)/(rhow*cw))*(1+(Tm/L)*(cw-ci-((1-W)/W)*(rhoso*cso/rhoi)))*(1/lambdaKob);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %time series.

itter=1;
plcoeff=1;    
nstorms=1;

% water_height=barrowWaves{1}.etas2Dc(:,buoy)-0.165-0.05;  % % mean water level relative to initial
% wave_period=barrowWaves{1}.Tmdyn2Dc(:,buoy);
% waveheight=barrowWaves{1}.Hmdyn2Dc(:,buoy);

% these data go through 2012. 
water_height2=hourlywaves.etas2Dc(:,buoy)-0.165-0.6;  % % mean water level relative to initial
wave_period2=hourlywaves.Tmdyn2Dc(:,buoy);              % 0.75 is too large, 0.5 to litt. 
waveheight2=hourlywaves.Hmdyn2Dc(:,buoy);

a=find(~isnan(t2));
water_height=interp1(t2(a), water_height2(a), tmodel)';
wave_period=interp1(t2(a), wave_period2(a), tmodel)';
waveheight=interp1(t2(a), waveheight2(a), tmodel)';

% load barrow Air Temp and apply the transfer function
load('justBarrowAirT')
air_temp=interp1(tAir, airT, t)+0.5;

spar=[];
wtmethod='mod';
water_temp=waterTempGenerator(t, spar, wtmethod);
fprintf(['Starting Modeling Runs:' toc])



%% %just the 3 initial runs.
%Permafrost Temperature Varies Through Time
deltaTstart=11.1;
deltaTend=7.5;
deltaT=deltaTstart+(deltaTend-deltaTstart)/(t(end)-t(1)).*(t-t(1));
beta_white=(L*rhoi)./(W*L*rhoi+rhobulk*cbulk.*deltaT);
beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?
lambdaKob=(L*rhoi*W)./(W*L*rhoi+rhobulk*cbulk.*deltaT);

for k=1:length(subMarineModel)
    
    outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_FullRunNoChange', '.mat');
    fprintf([outPath '\n'])

    plcoeff=1;
    if k==1
        method='white';
        beta=beta_white;

        plcoeff=0;
    elseif k==2
        method='rh';
        beta=beta_white;

        plcoeff=0;
    elseif k==3;
        plcoeff=0;
        method='kob/ravens';
        beta=lambdaKob;
    end
%     if k==1
%         plot(t, beta)
%     end



%    calculate melt rates (this could move to calling function)
    [m m_air]=meltrate(water_height, waveheight, water_temp, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
    m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity
    
    sucess=0;
    stop=0;
        
    while (sucess<4)&&(stop==0)
        
         try
            topple0501fxn(outPath, t, dt, obsiceon, water_height, waveheight, m, m_air,method);
            stop=1;
         catch
            fprintf('Failed \n')
            sucess=sucess+1;
         end  
    end

    fprintf([ num2str(toc) ' seconds elapsed \n'] )
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
    itter=itter+1;
    
               
end


%% sea ice does not change through time
    
%Permafrost Temperature Varies Through Time
deltaTstart=11.1;
deltaTend=7.5;
deltaT=deltaTstart+(deltaTend-deltaTstart)/(t(end)-t(1)).*(t-t(1));
beta_white=(L*rhoi)./(W*L*rhoi+rhobulk*cbulk.*deltaT);
beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?
lambdaKob=(L*rhoi*W)./(W*L*rhoi+rhobulk*cbulk.*deltaT);

% need different sea ice AND different water temperature
shorticeon=shortseaiceprep(t);    
short_water_temp=waterTempGenerator(t, spar, 'modShort');

for k=1:length(subMarineModel)
    
    outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_FullRun_SeaIce', '.mat');
    fprintf([outPath '\n'])

    plcoeff=1;
    if k==1
        method='white';
        beta=beta_white;

        plcoeff=0;
    elseif k==2
        method='rh';
        beta=beta_white;

        plcoeff=0;
    elseif k==3;
        plcoeff=0;
        method='kob/ravens';
        beta=lambdaKob;
    end
%     if k==1
%         plot(t, beta)
%     end
%    calculate melt rates (this could move to calling function)
    [m m_air]=meltrate(water_height, waveheight, short_water_temp, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
    m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity
    
    sucess=0;
    stop=0;

    while (sucess<4)&&(stop==0)
        
         try
            topple0501fxn(outPath, t, dt, shorticeon, water_height, waveheight, m, m_air,method);
            stop=1;
         catch
            fprintf('Failed \n')
            sucess=sucess+1;
         end  
    end

    fprintf([ num2str(toc) ' seconds elapsed \n'] )
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
    itter=itter+1;
    
                
end



%% PF temp does not change though time 

deltaTs=[4, 7.5, 11.1];
deltaTString={'04', '75', '11'};
%offset Permafrost Temperature
for k=1:length(subMarineModel)
   
    for j=1:numel(deltaTs)
        deltaT=deltaTs(j);
        beta_white=(L*rhoi)/(W*L*rhoi+rhobulk*cbulk*deltaT);
        beta_kob=2;
        Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?
        lambdaKob=(L*rhoi*W)/(W*L*rhoi+rhobulk*cbulk*deltaT);
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_FullRun_PFTemp_', deltaTString{j},'.mat');
        fprintf([outPath '\n'])

        plcoeff=1;
        
        
        if k==1
            method='white';
            beta=beta_white;

            plcoeff=0;
        elseif k==2
            method='rh';
            beta=beta_white;

            plcoeff=0;
        elseif k==3;
            plcoeff=0;
            method='kob/ravens';
            beta=lambdaKob;
        end
        
    %    calculate melt rates (this could move to calling function)
        [m m_air]=meltrate(water_height, waveheight, water_temp, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
        m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity
        
        sucess=0;
        stop=0;
        
        while (sucess<4)&&(stop==0)
             try
                topple0501fxn(outPath, t, dt, obsiceon, water_height, waveheight, m, m_air,method);
                stop=1;
             catch
                fprintf('Failed \n')
                sucess=sucess+1;
             end  
        end

        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
        
        
    end
                
end


%% % Level Change
% Permafrost Temperature Varies Through Time
deltaTstart=11.1;
deltaTend=7.5;
deltaT=deltaTstart+(deltaTend-deltaTstart)/(t(end)-t(1)).*(t-t(1));
beta_white=(L*rhoi)./(W*L*rhoi+rhobulk*cbulk.*deltaT);
beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?
lambdaKob=(L*rhoi*W)./(W*L*rhoi+rhobulk*cbulk.*deltaT);


for k=1:length(subMarineModel)
     for  q=1:length(levelChange)
    
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_FullRun','_varyLevel_',levelChange{q}, '.mat');
        fprintf([outPath '\n'])

        plcoeff=1;
        if k==1
            method='white';
            beta=beta_white;

            plcoeff=0;
        elseif k==2
            method='rh';
            beta=beta_white;

            plcoeff=0;
        elseif k==3;
            plcoeff=0;
            method='kob/ravens';
            beta=lambdaKob;
        end

        
        levelFactor=1;
        
        if q==1
            levelFactor=0.5;
        elseif q==2
            levelFactor=2;
        elseif q==3
            levelFactor=0.25;
        elseif q==4
            levelFactor=4;
        end
        
        waterHeightModel=levelFactor.*water_height;
        
%       calculate melt rates (this could move to calling function)
 
        [m m_air]=meltrate(waterHeightModel, waveheight, water_temp, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
        m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity

        sucess=0;
        stop=0;
        
        while (sucess<4)&&(stop==0)
        
            try
            	topple0501fxn(outPath, t, dt, obsiceon, waterHeightModel,waveheight, m, m_air,method);

                stop=1;
            catch
                fprintf('Failed \n')
                sucess=sucess+1;
            end  
        
        end
        

        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
                
    end
end


%% Wave Change

%Permafrost Temperature Varies Through Time
deltaTstart=11.1;
deltaTend=7.5;
deltaT=deltaTstart+(deltaTend-deltaTstart)/(t(end)-t(1)).*(t-t(1));
beta_white=(L*rhoi)./(W*L*rhoi+rhobulk*cbulk.*deltaT);
beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?
lambdaKob=(L*rhoi*W)./(W*L*rhoi+rhobulk*cbulk.*deltaT);

for k=1:length(subMarineModel)
     for  q=1:length(levelChange)
    
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_FullRun','_varyWave_',levelChange{q}, '.mat');
        fprintf([outPath '\n'])

        plcoeff=1;
        if k==1
            method='white';
            beta=beta_white;

            plcoeff=0;
        elseif k==2
            method='rh';
            beta=beta_white;

            plcoeff=0;
        elseif k==3;
            plcoeff=0;
            method='kob/ravens';
            beta=lambdaKob;
        end
        
        waveFactor=1;
        if q==1
            waveFactor=0.5;
        elseif q==2
            waveFactor=2;
        elseif q==3
            waveFactor=0.25;
        elseif q==4
            waveFactor=4;
        end
        
        waveHeightModel=waveFactor.*waveheight;
        
     %   calculate melt rates (this could move to calling function)
        [m m_air]=meltrate(water_height, waveHeightModel, water_temp, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
        m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity

        sucess=0;
        stop=0;
        
        while (sucess<4)&&(stop==0)
        
            try
                topple0501fxn(outPath, t, dt, obsiceon, water_height, waveHeightModel, m, m_air,method);
                stop=1;
            catch
                fprintf('Failed \n')
                sucess=sucess+1;
            end  
        end

        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
                
    end
end


%% Temp Change
%Permafrost Temperature Varies Through Time
deltaTstart=11.1;
deltaTend=7.5;
deltaT=deltaTstart+(deltaTend-deltaTstart)/(t(end)-t(1)).*(t-t(1));
beta_white=(L*rhoi)./(W*L*rhoi+rhobulk*cbulk.*deltaT);
beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?
lambdaKob=(L*rhoi*W)./(W*L*rhoi+rhobulk*cbulk.*deltaT);

for k=1:length(subMarineModel)
     for  s=1:length(tOffsetStr)
        tOf=tOffset(s);
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_FullRun','_varyTemp_',tOffsetStr{s}, '.mat');
        fprintf([outPath '\n'])

        plcoeff=1;
        if k==1
            method='white';
            beta=beta_white;

            plcoeff=0;
        elseif k==2
            method='rh';
            beta=beta_white;

            plcoeff=0;
        elseif k==3;
            plcoeff=0;
            method='kob/ravens';
            beta=lambdaKob;
        end

        
        
        
      %  calculate melt rates (this could move to calling function)
      
        [m m_air]=meltrate(water_height, waveheight, water_temp+tOf, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
        m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity

        sucess=0;
        stop=0;
        
        while (sucess<4)&&(stop==0)
        
            try
                topple0501fxn(outPath, t, dt, obsiceon, water_height, waveheight, m, m_air,method);
                stop=1;
            catch
                fprintf('Failed \n')
                sucess=sucess+1;
            end  
        end
        
      
        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
    end
end

%%  Beach Change
%Permafrost Temperature Varies Through Time
deltaTstart=11.1;
deltaTend=7.5;
deltaT=deltaTstart+(deltaTend-deltaTstart)/(t(end)-t(1)).*(t-t(1));
beta_white=(L*rhoi)./(W*L*rhoi+rhobulk*cbulk.*deltaT);
beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?
lambdaKob=(L*rhoi*W)./(W*L*rhoi+rhobulk*cbulk.*deltaT);

for k=1:length(subMarineModel)
     for  q=1:length(beachChange)
    
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_FullRun','_varyBeach_',beachStr{q}, '.mat');
        fprintf([outPath '\n'])

        plcoeff=1;
        if k==1
            method='white';
            beta=beta_white;

            plcoeff=0;
        elseif k==2
            method='rh';
            beta=beta_white;

            plcoeff=0;
        elseif k==3;
            plcoeff=0;
            method='kob/ravens';
            beta=lambdaKob;
        end
        
        waterHeightModel=water_height+beachChange(q);
        
        % calculate melt rates (this could move to calling function)

        [m m_air]=meltrate(waterHeightModel, waveheight, water_temp, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
        m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity

        sucess=0;
        stop=0;
       
        while (sucess<4)&&(stop==0)
        
            try
            	topple0501fxn(outPath, t, dt, obsiceon, waterHeightModel, waveheight, m, m_air,method);

                stop=1;
            catch
                fprintf('Failed \n')
                sucess=sucess+1;
            end  
    

        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
        end       
    end
end
