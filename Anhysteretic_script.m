%% Anhysteretic test script
% use this script to test the anhysteretic magnetization / magnetostriction
% calculation.
clear
clc

%add relevant folders to workspace
addpath('Subfunctions')
addpath('Data Sets')
addpath('Materials')

%% Reference Times (laptop)
% note - lab computer is 4x-5x faster
% running in serial mode on my laptop: ~2.3 seconds per point
% running in parallel on my laptop: ~ 1 second per point
% running in parallel on palpatine: 9 points per second

%% Control Options
options.DiagnosticPlot = false;
% options.loop = 'serial';      %serial or parallel computation style
options.loop = 'parallel';      %serial or parallel computation style
options.iterations = false;     %display iteration information during serial operation
options.crystalAvg = 'single';    %single or poly crystalline properties (Poly is NOT finished yet)

%start parallel processing pool if selected
switch options.loop
    case 'parallel'
        license checkout Distrib_Computing_Toolbox;
        distcomp.feature( 'LocalUseMpiexec', false );
        pool = gcp;
end

%% Constants
options.permeability_0 = 4*pi*1e-7;    %(m kg) / (s A)^2 == N/A^2
options.permitivity_0 =  8.854187817* 1e-12; %(F/m) = (C/(V m))
options.c0 = 1/sqrt(options.permeability_0*options.permitivity_0);

%adjust grids for computing integrals over all angles (more points = higher
%accuracy)
ngrid = 360;
options.theta = linspace(0,pi,ngrid);
options.phi = linspace(0,2*pi,ngrid);
[options.THETA, options.PHI] = meshgrid(options.theta ,options.phi);

%% Reference Material Properties
%this runs a script containing the relevant material properties
%make a new script for any new desired material, and store in the
%'Materials' folder

Galfenol_isotropic
% Galfenol
% Nickel

%% Magnetic Field Grid Vectors
% Magnetic field limits
Bmax = .05;         %T - max free space induction - equivalent to 1,000 Oe in free space
n = 50; %Number of test points to evaluate

h1 = 0;
h2 = 0;

%linearly ;increasing field
% h3 = linspace(0,Bmax,n)/options.permeability_0;             

%logarithmic spacing from -Hmax to Hmax
%spans 'n_orders' orders of magnitude
n_orders = 3;
h3 = logspace(log10(Bmax)-n_orders, log10(Bmax), round(n/2)-1)/options.permeability_0;    
h3 = [-fliplr(h3), 0, h3]; 

%% Applied Strain Grid Vectors
% Stress limits
Smax = 1e-3;        %(-) - max strain

% Applied Strain(Voigt Notation)
s1 = 0;
s2 = 0;
s3 = linspace(-Smax,Smax,n);  %note: can use logspace
s4 = 0;
s5 = 0;
s6 = 0;

%% sort all vectors
for i =1 : 3
    eval(['h',num2str(i),' = sort(h',num2str(i),');']);
end
for i =1 : 6
    eval(['s',num2str(i),' = sort(s',num2str(i),');']);
end

%% File / Grid Size
nGrid = numel(h1)*numel(h2)*numel(h3)*numel(s1)*numel(s2)*numel(s3)*numel(s4)*numel(s5)*numel(s6);
ptsPerSec = 1;
minEst = nGrid/ptsPerSec/60;
hoursEst = minEst/60;
daysEst = hoursEst/24;
file_size_est = 8*nGrid*1e-6; %MB per stored matrix

%% 9D Grid Array
%initialize data storate arrays

% %2D axis-symmetric models (H2 = S4 = S6 = 0)
% [H1,H3,S1,S2,S3,S5] = ndgrid(h1,h3,s1,s2,s3,s5);
% H2 = zeros(size(H1));
% S4 = H2; S6 = H2;
% %DONT CHANGE ANY VALUES AFTER USING NDGRID

%Alternate - If only 2 variables are being controlled
[H3, S3] = ndgrid(h3,s3);
H1 = zeros(size(H3));
H2 = H1; S1 = H1; S2 = H1; S4 = H1; S5 = H1; S6 = H1;

%% Create Grid structure / Test Grid for monotonic behavior
for i = [1,3]
    eval(['Grid.H',num2str(i),' = H',num2str(i),';']);
    %     eval(['Grid.M',num2str(i),' = M',num2str(i),';']);
end
for i = [1:3,5]
    eval(['Grid.S',num2str(i),' = S',num2str(i),';']);
    %     eval(['Grid.T',num2str(i),' = T',num2str(i),';']);
end

% %Make sure this doesn't throw an NDGRID error
% fake_M = rand(size(H1));
% interpn(H3, S3, fake_M, 0,0);

%% Loop over desired directions
%this part was going to be used to calculate polycrystalline behavior
%(rotation into the alpha direction), but I never finished implementing it.
%Just don't touch these two lines
options.alpha0 = [1 0 0]';
labels = strrep(num2str(options.alpha0'),' ','');

%% Nonlinear constitutive behavior
disp(['Beginning Crystal Cut: ',labels,' - ',datestr(datetime)])

%% Calculate Anhysteretic Behavior
%Z-direction of rotated crystal ([0 0 1]' for default setup);
%Tranformation matrix: Convert between coordinate systems
options.TM = transformationMatrix(options.alpha0,[1 0 0]');

options.nPoints = numel(H1); %number of test points
hplot = [];%initialize plot handle

%start timer
t_overall = tic;

%Magnetization / Magnetostrictive stress in standard xyz orientation
%Sm# - magnetostrictive strain
[ M1,M2,M3,...                                  %magnetization
    Tel1,Tel2,Tel3,Tel4,Tel5,Tel6,...           %elastic stress
    Tm1,Tm2,Tm3,Tm4,Tm5,Tm6,...                 %magnetoelastic stress
    Sm1,Sm2,Sm3,Sm4,Sm5,Sm6]...                 %magnetoelastic strain (magnetostriction)
    = AnhystereticMagnetizationLoop(H1,H2,H3,S1,S2,S3,S4,S5,S6,options,hplot);

%store run time
t_elapsed = toc(t_overall);

%display run time
displayStatus(t_elapsed, 1, 1)

%close parallel pool
delete(pool)

pts_per_sec = numel(M1)/t_elapsed;
disp(['points per second: ', num2str(pts_per_sec)])

%% Save Data
%create new directory for files
dir = [cd,'\Data Sets\',datestr(datetime('now'),'yyyy-mm-dd - v1')];
while exist(dir,'dir') == 7 %if directory already exists, increment version number by 1
    [ind1,ind2] = regexp(dir,' - v(\d+)'); %regular expression to find -v##
    num = dir(ind1+4:ind2); %pull out number
    dir = [dir(1:ind1+3),num2str(str2double(num)+1)]; %increment number by 1
end
dir = [dir,'\'];
mkdir(dir); %make the directory
    
save([dir,'magnetization'],'M1','M2','M3')                                  %magnetization components
save([dir,'elastic'],'Tel1','Tel2','Tel3','Tel4','Tel5','Tel6')    %elastic stress components
save([dir,'magnetostriction1'],'Tm1','Tm2','Tm3','Tm4','Tm5','Tm6')          %magnetostrictive stress components
save([dir,'magnetostriction2'],'Sm1','Sm2','Sm3','Sm4','Sm5','Sm6')         %magnetostrictive strain components
save([dir,'fieldGrid'],'H1','H2','H3','S1','S2','S3','S4','S5','S6')        %applied fields 
