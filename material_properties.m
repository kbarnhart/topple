function []=material_properties()

%% material parameters  
g=9.81;    % m/s2

rho=2000; %kg/m3
taupf=2e5; %pascals tensile strength on soil % from Hoque and Pollard, pg 1109 and ref theirin
tauice=1e4; %pascals tensile strength on icewedge % this value is made up...


%thermal constants (from Nora'm MS Table 1)
ks=1.5;  % dry soil (mineral and peat)	W/m/K
kw=0.58; % water W/m/K
ki=2.18; % ice W/m/K
		
cs=1000; % dry soil (mineral and peat) J/kg/K
cw=4210; % water J/kg/K
ci=2108; % ice  J/kg/K
		
rhos=1200; % dry soil (mineral and peat) kg/m3
rhow=1000; % water kg/m3
rhoi=917;  %ice kg/m3		

L=334000; % latent heat of fusion, H2O J/kg

W=.65; % ice content

kbulk=(ks^(1-W))*(ki^W);
cbulk=(cs*(1-W))+(ci*W);
rhobulk=(rhos*(1-W))+(rhoi*W);

deltaT=9; % temperature difference between permafrost and water