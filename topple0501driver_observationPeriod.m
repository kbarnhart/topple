close all
clear all
tic

mainFolder=cd;
experimentFolder='ObservedPaper1';

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
varyWaterLevel={half, doub, four, quad};
varyWaveHeight={half, doub, four, quad};


tOffset=-5:1:5;
tOffsetStr={'n5','n4','n3', 'n2','n1','00','p1','p2','p3','p4','p5'};

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
% load air temp, water temp, wave climate -- how to deal with NaNs
load all_drewpoint_data

waterTemp=levellogger.watertemp;
t_water_temp=levellogger.date;

% wavelogger
% wavelogger offset. From the marine cam movie it looks like the water is
% at the base of the blocks (0m for the model) an August 16th, 2010 at
% around 9:20 AM

% first find the level for that day and subtract from the levelogger data
% to ofsett corectly
offsettime=datenum([2010 8 18 9 20 0]);
off_ind= find(waves2010.date>offsettime, 1, 'first') ;
offset=waves2010.mdepth(off_ind);
waves2010.depth=waves2010.mdepth-offset-0.18;

setUp=waves2010.depth;
t_water_height=waves2010.date;

wave_period=waves2010.tp;
t_wave_period=waves2010.date;

wave_height=waves2010.hsig;
t_wave_height=waves2010.date;

air_temp=hourlymet.Tair;
t_air_temp=hourlymet.date;
%%
t=t_wave_period;
dt=t(2)-t(1);
tstart=t(1);
tend=datenum([2010 8 23 0 0 0]);
%% Sea Ice Analysis Parmeters
% % observed sea ice
obsiceon=seaiceprep(tstart:dt:tend);


%watertemp Simple Sine Model
spar.Ayw=10;
spar.Mw=-2;
spar.Adw=0.5;
spar.D=100; % offset

%%%%%%%%%%%%%%%%%%%%%%% permafrost characteristics %%%%%%%%%%%%%%%%%%%%%%%%
deltaT=9;               % degrees C         % temperature difference between permafrost and zero
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
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MODELED WAVES%%%%%%%%%%%%%%%%%
load WaveModelNov2012
buoy=6;
tMODEL=linspace(min(barrowWaves{1}.date),max(barrowWaves{1}.date), numel(barrowWaves{1}.date)); 
waterHeightModeled=barrowWaves{1}.etas2Dc(:,buoy); 
wavePeriodModeled=barrowWaves{1}.Tmdyn2Dc(:,buoy); 
waveHeightModeled=barrowWaves{1}.Hmdyn2Dc(:,buoy); 

% tstart=min(barrowWaves{1}.date);
% tend=max(barrowWaves{1}.date);
% dt=1/24;
load modeledTemperaturesNov2012
waterTempModeled=interp1(SSTModel.date, SSTModel.Twater,tMODEL);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%OBSERVED WAVES%%%%%%%%%%%%%%%%

obsiceon=seaiceprep(tstart, tend, dt);


% coordinate env. parameters to the same time step
[~, obs_water_temp, ~, obs_water_height, ~, wave_period,...
    ~, air_temp, ~, obs_waveheight, ~, obsiceon, ...
    ~, waterHeightModeled,~, wavePeriodModeled, t, waveHeightModeled...
    ~, waterTempModeled] ...
    = timesync(timetype, cuttype, interptype, ...
    t_water_temp, waterTemp, t_water_height, setUp, t_wave_period, wave_period, ...
    t_air_temp, air_temp, t_wave_height, wave_height, tstart:dt:tend, obsiceon,...
    tMODEL, waterHeightModeled,tMODEL, wavePeriodModeled, tMODEL, waveHeightModeled,...
    tMODEL, waterTempModeled); 

dt=t(2)-t(1);
tstart=t(1);
tend=t(end);


%%
beta_white=(L*rhoi)/(W*L*rhoi+rhobulk*cbulk*deltaT);

beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?

lambdaKob=(L*rhoi*W)/(W*L*rhoi+rhobulk*cbulk*deltaT);
lambdaKob=lambdaKob*(1/3); % change so that "effective notch depth for bluff is 3 m insetad of one)
% zeta_kobayashi=((beta_kob*W*rhoi*L)/(rhow*cw))*(1+(Tm/L)*(cw-ci-((1-W)/W)*(rhoso*cso/rhoi)))*(1/lambdaKob);

%%
fprintf(['Starting Modeling Runs:' toc])
itter=1;

% just the different erosionModels
for k=1:length(subMarineModel)
    outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_NoChanges.mat');

    fprintf([outPath, '\n'])

    setUp=obs_water_height;                   
    waterTemp=obs_water_temp;
    waveHeight=obs_waveheight;
    
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
  
    [m m_air]=meltrate(setUp, waveHeight, waterTemp, wave_period, air_temp, subair_coeff, plcoeff, method,beta);

    m = m*(60*60*24); %converts to m/day 
     
    try
         topple0501fxn_observationPeriod(outPath, t, dt, obsiceon, setUp, waveHeight, m, m_air, method);
    catch
         fprintf('failed')
    end
    
    fprintf([ num2str(toc) ' seconds elapsed \n'] )
    fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
    itter=itter+1;                    
end


% variable water level
for k=1:length(subMarineModel)
    for  q=1:length(varyWaterLevel)
                
                   
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_varyLevel_',varyWaterLevel{q}, '.mat');
        fprintf([outPath, '\n'])
        
        setUp=obs_water_height;                   
        waterTemp=obs_water_temp;
        waveHeight=obs_waveheight;

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
              
        if q==1
            setUp=setUp./2;
        elseif q==2
            setUp=setUp.*2;
        elseif q==3
            setUp=setUp./4;
        elseif q==4
            setUp=setUp.*4;
        end


        beta_white=(L*rhoi)/(W*L*rhoi+rhobulk*cbulk*deltaT);
        [m m_air]=meltrate(setUp, waveHeight, waterTemp, wave_period, air_temp, subair_coeff, plcoeff, method,beta);
        

        m = m*(60*60*24); %converts to m/day and incorporate change due to heat capacity

        try
            topple0501fxn_observationPeriod(outPath, t, dt, obsiceon, setUp, waveHeight, m, m_air, method);
        catch
        end

        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
                   
    end
end

% wave height

for k=1:length(subMarineModel)
    for  r=1:length(varyWaveHeight)
                
                   
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_varyWave_',varyWaveHeight{r}, '.mat');
        fprintf([outPath, '\n'])
        
        setUp=obs_water_height;                   
        waterTemp=obs_water_temp;
        waveHeight=obs_waveheight;

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
                           
        if r==1
            waveHeight=waveHeight./2;
        elseif r==2
            waveHeight=waveHeight.*2;
        elseif r==3
            waveHeight=waveHeight./4;
        elseif r==4
            waveHeight=waveHeight.*4;
        end
       
        beta_white=(L*rhoi)/(W*L*rhoi+rhobulk*cbulk*deltaT);
        [m m_air]=meltrate(setUp, waveHeight, waterTemp, wave_period, air_temp, subair_coeff, plcoeff, method,beta);

        m = m*(60*60*24); %converts to m/day and incorporate change due to heat capacity


        try
            topple0501fxn_observationPeriod(outPath, t, dt, obsiceon, setUp, waveHeight, m, m_air, method);
        catch
        end

        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
                   
    end
end


% Temperature
for k=1:length(subMarineModel)
    for  s=1:length(tOffset)
        
        tOffs=tOffset(s);
                   
        outPath=strcat(mainFolder, '/', experimentFolder, '/', subMarineModel{k}, '_varyTemp_',tOffsetStr{s}, '.mat');
        fprintf([outPath, '\n'])
        
        setUp=obs_water_height;                   
        waterTemp=obs_water_temp+tOffs;
        waveHeight=obs_waveheight;

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
       
        beta_white=(L*rhoi)/(W*L*rhoi+rhobulk*cbulk*deltaT);
        [m m_air]=meltrate(setUp, waveHeight, waterTemp, wave_period, air_temp, subair_coeff, plcoeff, method,beta);

        m = m*(60*60*24); %converts to m/day and incorporate change due to heat capacity

        try
            topple0501fxn_observationPeriod(outPath, t, dt, obsiceon, setUp, waveHeight, m, m_air, method);
        catch
        end

        fprintf([ num2str(toc) ' seconds elapsed \n'] )
        fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n \n \n')
        itter=itter+1;
                   
    end
end
