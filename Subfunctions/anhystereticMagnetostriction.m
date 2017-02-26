function [  Tel1,Tel2,Tel3,Tel4,Tel5,Tel6,Tm1,Tm2,Tm3,Tm4,Tm5,Tm6,...
    Sm1,Sm2,Sm3,Sm4,Sm5,Sm6,options,varargout ]...
    = anhystereticMagnetostriction( H1,H2,H3,S1,S2,S3,S4,S5,S6,options,idx ,varargin )
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
U =@(theta,phi,H,S) energyTerms(alpha1(theta,phi),...
    alpha2(theta,phi),...
    alpha3(theta,phi),...
    alpha1_rot(theta,phi),...
    alpha2_rot(theta,phi),...
    alpha3_rot(theta,phi),...
    H,S,options);

%% Statistical Averaging
%target functions: Stretches 
% s_b1b2b3 = @(theta,phi, beta1,beta2,beta3) 3/2*S100.*(...
%     beta1.^2.*alpha1(theta,phi).^2 +...
%     beta2.^2.*alpha2(theta,phi).^2 +...
%     beta3.^2.*alpha2(theta,phi).^2 -1/3) + ...
%     3*S111.*(...
%     beta1.*beta2.*alpha1(theta,phi).*alpha2(theta,phi) + ...
%     beta1.*beta3.*alpha1(theta,phi).*alpha3(theta,phi) + ...
%     beta2.*beta3.*alpha2(theta,phi).*alpha3(theta,phi) ...
%     );
% s100 = @(theta,phi) sb1b2b3(theta,phi,1,0,0);
% s010 = @(theta,phi) sb1b2b3(theta,phi,0,1,0);
% s001 = @(theta,phi) sb1b2b3(theta,phi,0,0,1);
% s110 = @(theta,phi) sb1b2b3(theta,phi,pi/4,pi/4,pi/2);
% s101 = @(theta,phi) sb1b2b3(theta,phi,pi/4,pi/2,pi/4);
% s011 = @(theta,phi) sb1b2b3(theta,phi,pi/2,pi/4,pi/4);

%magnetostrictive strains:
s11 = @(theta,phi) -B1./(C11-C12)*(alpha1_rot(theta,phi).^2-1/3);
s22 = @(theta,phi) -B1./(C11-C12)*(alpha2_rot(theta,phi).^2-1/3);
s33 = @(theta,phi) -B1./(C11-C12)*(alpha3_rot(theta,phi).^2-1/3);
s23 = @(theta,phi) -B2./(C44)*(alpha2_rot(theta,phi).*alpha3_rot(theta,phi));
s13 = @(theta,phi) -B2./(C44)*(alpha1_rot(theta,phi).*alpha3_rot(theta,phi));
s12 = @(theta,phi) -B2./(C44)*(alpha1_rot(theta,phi).*alpha2_rot(theta,phi));

switch crystalAvg
    case 'poly'     
        %Free magnetostrictive Strains
        [lambda(1)] = averageProperties( U, Omega, H, S, {s11}, Lambda100,options );
        lambda(2) = 0;
        lambda(3) = 0;
        lambda(4) = 0;
        lambda(5) = 0;
        lambda(6) = 0;
        
    case 'single'                
        %Free magnetostrictive Strains
        [lambda(1), lambda(2), lambda(3), lambda(4), lambda(5), lambda(6)] = ...
            averageProperties( U, Omega, H, S, {s11,s22,s33,s23,s13,s12}, Lambda100, options );
end

%% store magnetostriction for output
%store output data
for i = 1:6
    %Sm# = lambda(#);
    eval(['Sm',num2str(i),' = lambda(',num2str(i),');'])
end

%% Calculate Magnetostrictive stress
%determine the stress required to cause the observed magnetostriction
Tm = stiffness*lambda';

%store output data
for i = 1:6
    %Tm# = Tm(#);   
    eval(['Tm',num2str(i),' = Tm(',num2str(i),');'])
end

%% Calculate Elastic stress
%determine the stress required to cause the observed magnetostriction
Tel = stiffness*(S-lambda');

%store output data
for i = 1:6
    %Tel# = Tel(#);
    eval(['Tel',num2str(i),' = Tel(',num2str(i),');'])
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
