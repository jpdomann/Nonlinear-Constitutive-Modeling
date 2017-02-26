function [ M1,M2,M3,options,varargout ] = anhystereticMagnetization( H1,H2,H3,...
    S1,S2,S3,S4,S5,S6,options,idx ,varargin)
%ANHYSTERETICPROPERTIES Summary of this function goes here
%   Detailed explanation goes here

%% Timer start
start_time = tic;
stop_time = options.stop_time;

%% Sort / Store Input

%return options as variables
parseStructure(options);
if nargin==12
    hplot = varargin{1};
else
    hplot = [];
end

%Magnetic field vector (each column in a new vector)
H = [H1(:), H2(:), H3(:)]';
%Strain Vector (each column in a new vector)
S = [S1(:),S2(:),S3(:),S4(:),S5(:),S6(:),]';

%% Energy Expressions
       
% %Tranformation matrix: Convert between coordinate systems
% TM = transformationMatrix([1  0 0]',[0 0 1]');

%direction cosines
[alpha1,alpha2,alpha3,alpha1_rot,alpha2_rot,alpha3_rot] = directionCosines(TM);

%Total
U =@(theta,phi,H,S) energyTerms(...
    alpha1(theta,phi),...
    alpha2(theta,phi),...
    alpha3(theta,phi),...
    alpha1_rot(theta,phi),...
    alpha2_rot(theta,phi),...
    alpha3_rot(theta,phi),...
    H,S,options);

%% Statistical Averaging
%target functions
Mx = @(theta,phi) Ms.*alpha1(theta,phi);
My = @(theta,phi) Ms.*alpha2(theta,phi);
Mz = @(theta,phi) Ms.*alpha3(theta,phi);

switch crystalAvg
    case 'poly'
        %For polycrystals - field / stress is only applied in X direction
        [M1] = averageProperties( U, Omega, H, S, {Mx}, Ms,options );
        M2 = 0;
        M3 = 0;
        
    case 'single'
        [M1, M2, M3] = averageProperties( U, Omega, H, S, {Mx,My,Mz}, Ms,options );
end

%% Energy Landscape Plots
if DiagnosticPlot
    hplot = energyPlots(U,H,S,hplot,options);
end
varargout{1} = hplot;

%% Timer stop
if options.iterations
    stop_time(idx) = toc(start_time);
    options.stop_time = stop_time;
    idx = sum(stop_time~=0);
    displayStatus(stop_time, nPoints, idx)
end

end
