close all
clear all
tic

mainFolder=cd;
experimentFolder='paperFullRun05';


whiteFN='whMethod';
rhFN='rhMethod';
krFN='krMethod';
plFN='plMethod';

subMarineModel={whiteFN, rhFN, krFN};%, plFN};

full='full';
half='half';
doub='doub';

waveChange={full, half, doub};
levelChange={full, half, doub};
beachChange=[-0.2:0.05:0.2];

beachStr={'n20','n15','n10', 'n05','00','p05','p10','p15','p20'};


if ~exist(experimentFolder, 'dir')
    mkdir(experimentFolder)
end


tOffset=-5:1:5;
tOffsetStr={'n5','n4','n3', 'n2','n1','00','p1','p2','p3','p4','p5'};

%%
load /Users/katherinebarnhart/MATLABwork/SeaIce/WaveModelNov2012
buoy=6;


t=barrowWaves{1}.date;


tstart=min(barrowWaves{1}.date);
tend=max(barrowWaves{1}.date);
dt=1/24;

%t=tstart:dt:tend;

storms=1;

numit=1;

%%%% storm parameters %%%%%%%%
% storms
spar.maxduration=10; %days
spar.maxintensity=2; %m water level

%airtemp
spar.Ay=-17.7;
spar.Ad=-1.15;
spar.M=-10.8;
spar.Dy=-16; % offset
spar.Dd=0.41; % offset

%watertemp
spar.Ayw=10;
spar.Mw=-2;
spar.Adw=0.5;
spar.D=100; % offset

% wave period
spar.Mp=4;
spar.STp=1.5;

%wave heights % gamma distribution fits
spar.a=5.7;
spar.b=0.23;


%%% % complex sine option

spar.a0 = 3.075;
spar.a1 = -1.844;  
spar.b1 = 4.477;
spar.w = 0.03643;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % observed sea ice
obsiceon=seaiceprep(t);
% futureiceon=futureseaice(tstart, tend, dt);
    
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

%%%%%

%%

%%
deltaTstart=100;
deltaTend=0;

deltaT=deltaTstart+(deltaTend-deltaTstart)/(t(end)-t(1)).*(t-t(1));
% plot(t, deltaT)
% datetick

beta_white=(L*rhoi)./(W*L*rhoi+rhobulk*cbulk.*deltaT);

beta_kob=2;
Tm=-1; % half way between zero (bluff melting) and -2, sea water freezing?

lambdaKob=(L*rhoi*W)./(W*L*rhoi+rhobulk*cbulk.*deltaT);
% zeta_kobayashi=((beta_kob*W*rhoi*L)/(rhow*cw))*(1+(Tm/L)*(cw-ci-((1-W)/W)*(rhoso*cso/rhoi)))*(1/lambdaKob);


plot(t, lambdaKob, t, beta_white)
datetick


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %time series.

itter=1;
plcoeff=1;    
nstorms=1;

water_height=barrowWaves{1}.etas2Dc(:,buoy)-0.15;  % % mean water level relative to initial
wave_period=barrowWaves{1}.Tmdyn2Dc(:,buoy);
waveheight=barrowWaves{1}.Hmdyn2Dc(:,buoy);
[~, ~, ~, air_temp, ~]=stormgenerator(t, nstorms, spar);

wtmethod='mod';
water_temp=waterTempGenerator(t, spar, wtmethod);
%%



     beta=beta_white;

    % calculate melt rates (this could move to calling function)
    [m m_air]=meltrate(water_height, waveheight, water_temp, wave_period, air_temp, subair_coeff, plcoeff, method, beta);
    m = m*(3600*24); %converts to m/day and incorporate change due to heat capacity
