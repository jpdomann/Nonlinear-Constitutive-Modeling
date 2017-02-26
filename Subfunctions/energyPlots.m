function [ h ] = energyPlots( U,H,S,h,options )
%ENERGYPLOTS Summary of this function goes here
%   Detailed explanation goes here

THETA = options.THETA;
PHI = options.PHI;

%Spherical coordinates
AZ = PHI;   %azimuth
EL = pi/2 - THETA ; %elevation from xy-plane

%Use energy as color and radius coordinate
R = U(THETA,PHI,H,S)-min(min(U(THETA,PHI,H,S)));
% R = (U(THETA,PHI,H,T)); 
C = R;

%convert to cartesian coordinates
[X,Y,Z] = sph2cart(AZ,EL,R);
% R=sqrt(X.^2 + Y.^2 + Z.^2);

figure(1)

if ~isempty(h)
    hax = subplot(1,2,1);
    h(1).XData = X;
    h(1).YData = Y;
    h(1).ZData = Z;
    h(1).CData = C;
    
    hax.XLimMode = 'auto';
    hax.YLimMode = 'auto';
    hax.ZLimMode = 'auto';    
    centerAxis
    
    hax = subplot(1,2,2);
    h(2).XData = THETA;
    h(2).YData = PHI;
    h(2).ZData = C;
    h(2).CData = C;
    
    hax.ZLim = [min(R(:)),max(R(:))];
    
else
    clear h
    subplot(1,2,1)
    h(1) = surf(X,Y,Z,C);
    centerAxis
    
    hax = subplot(1,2,2);
    h(2) = surf(THETA,PHI,C);
    hax.XLim = [0 pi];
    hax.YLim = [0 2*pi];
    hax.ZLim = [min(R(:)),max(R(:))];
    format_ticks(gca,{'0', '\pi/4', '\pi/2', '3\pi/4', '\pi'},...
        {'0', '\pi/2', '\pi', '3\pi/2', '2\pi'},...
        0:pi/4:pi, 0:pi/2:2*pi)   ;
    xlabel('\theta')
    ylabel('\phi')
    zlabel('Energy (J)')
end


for i = 1:numel(h)
    h(i).EdgeAlpha = 0;
    h(i).FaceColor = 'interp';
end

drawnow

end

