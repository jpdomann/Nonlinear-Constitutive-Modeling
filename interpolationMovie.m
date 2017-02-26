function interpolationMovie

clear
clc

%% Load data
%directory of stored data
dir = [cd,'\Data Sets\2017-02-25 - v4\'];
addpath(dir);
addpath('Subfunctions')
load([dir,'fieldGrid.mat'])             %applied fields
load([dir,'magnetization.mat'])         %magnetization
load([dir,'elastic.mat'])               %elastic stress
load([dir,'magnetostriction1.mat'])     %magnetoelastic stress
load([dir,'magnetostriction2.mat'])     %magnetoelastic strain

%{
Variables loaded in this sectionl:
Applied Fields:
H - applied magnetic field
S - applied strain (total strain on material)

Resultant fields:
M - magnetization
Sm - magnetostriction
Tm - magnetoelastic stress (body stress required to create the magnetostriction)
Tel - elastic stress (this is what would be measured by a load cell)
%}

%% Options
%constants
mu0 = 4*pi*1e-7;        %permeability of free space

%interpolation options
method = 'spline';      %interpolation method ('linear','nearest','cubic','spline')
n_intperp = 3e2;        %number of points to interpolate

%plotting options
edgeaA = .01;   %edgealpha for surface plots (controls opacity)
colors = [...
    0 .45 .74;...
    .47 .67 .19];   %line colors (reference, moving)
marker = '.';
markersize = 10;
linewidth = 8;
fontsize = 14;
fontweight = 'bold';

%movie options
create_movies = true;
duration = 10;  %seconds

%% Interpolation

%Vector of points to make grids out of
h3interp = linspace(min(H3(:)),max(H3(:)), n_intperp);
s3interp = linspace(min(S3(:)),max(S3(:)), n_intperp);

% meshgrid
[H3interp,S3interp] = meshgrid(h3interp,s3interp);

% %transpose to match original grids
H3interp = H3interp';
S3interp = S3interp';


%% Field Calculations
Sel3 = S3 - Sm3;            % Elastic Strain
B3 = mu0 .* (H3 + M3);      % Magnetic flux density

%% Interpolate
%create anonymous function to interpolate any fields as desired
int_func = @(Y) interpn(H3,S3,Y,H3interp,S3interp,method);

M3interp = int_func(M3);
B3interp = int_func(B3);
Tel3interp = int_func(Tel3);


%% Material Properties - Original Data
% dF/dX = numDiv(X,F,dim)
E = numDiv(S3,Tel3,2);          %Modulus of elasticity
chi = numDiv(H3,M3,1);          %magnetic susceptibility
mu = numDiv(H3,B3,1)./mu0;      %relative permeability
q1 = numDiv(Tel3,B3,2);         %piezomagnetic sensing coefficient
q2 = numDiv(H3,Sel3,1);         %piezomagnetic actuation coefficient
k2 = q2.^2.*E./(mu0.*mu); %coupling coefficient: (I came up with this using dimensional analysis, NEEDS TO BE CHECKED)


%% Material Properties - Interpolated Data
Einterp = numDiv(S3interp,Tel3interp,2);
chiinterp = numDiv(H3interp,M3interp,1);
muinterp = numDiv(H3interp,B3interp,1)./mu0;
q1interp = numDiv(Tel3interp,M3interp,2);
q2interp = numDiv(H3interp,S3interp,1)/(4*pi*1e-7);
k2interp = q2interp.^2.*Einterp./(mu0.*muinterp);


%% Plots
%anonymous function to make all plots the same style
s_plot = @(Z) surf(H3,S3,Z,'EdgeAlpha',edgeaA,'FaceColor','interp');
s_interp_plot = @(Z) surf(H3interp,S3interp,Z,'EdgeAlpha',edgeaA,'FaceColor','interp');

%% Plot 1 - Original Data
hfig = figure(1);
clf
hax1_1 = subplot(1,2,1);
h1_1 = s_plot(M3);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('M (A/m)')

hax1_2 = subplot(1,2,2);
h1_2 = s_plot(Tel3);
hax1_2.YScale = 'linear';
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('\sigma (Pa)')

%% Plot 2 - Interpolated Data
hfig = figure(2);
clf
hax2_1 = subplot(1,2,1);

h2_1 = s_interp_plot(M3interp);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('M (A/m)')

hax2_2 = subplot(1,2,2);
h2_2 = s_interp_plot(Tel3interp);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('\sigma (Pa)')

%% Plot 3 - Original Data Slopes
hfig = figure(3);
clf
hax3_1 = subplot(2,2,1);
h3_1 = s_plot(mu);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('\mu_r (-)')
% view(2)

hax3_2 = subplot(2,2,2);
h3_2 = s_plot(q1);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('q_1 (m/A)')
% view(2)

hax3_3 = subplot(2,2,3);
h3_3 = s_plot(q2);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('q_2 (m/A)')
% view(2)

hax3_4 = subplot(2,2,4);
h3_4 = s_plot(E);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('E (Pa)')
% view(2)

%% Plot 4 - Interpolated Data Slopes
hfig = figure(4);
clf
hax4_1 = subplot(2,2,1);
h4_1 = s_plot(mu);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('\mu_r (-)')
% view(2)

hax4_2 = subplot(2,2,2);
h4_1 = s_plot(q1);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('q_1 (m/A)')
% view(2)

hax4_3 = subplot(2,2,3);
h4_1 = s_plot(q2);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('q_2 (m/A)')
% view(2)

hax4_4 = subplot(2,2,4);
h4_4 = s_plot(E);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('E (Pa)')
% view(2)

%% Plot 5 - Coupling Coefficient
figure(5)
clf
hax5_1 = axes;
h5_1 = s_plot(k2);
xlabel('H (A/m)')
ylabel('\epsilon (-)')
zlabel('k^2 (-)')
% view(2)


%% Plot 6 - MvsH Movie - Original Data

XLabel = 'H (A/m)';
YLabel = 'M (A/m)';
F{1} = animateCurves(6,1,H3,M3,H3(:,end),M3(:,end),XLabel,YLabel,fontsize,fontweight,...
    linewidth,marker,markersize,colors);
titles{1} = 'M vs H - original data';

%% Plot 7 - stress vs strain Movie - Original Data

XLabel = '\epsilon ()';
YLabel = '\sigma (Pa)';
F{2} = animateCurves(7,2,S3,Tel3,S3(1,:),Tel3(1,:),XLabel,YLabel,fontsize,fontweight,...
    linewidth,marker,markersize,colors);
titles{2} = 'stress vs strain - original data';

%% Plot 8 - stiffness vs strain Movie - Original Data

XLabel = '\epsilon ()';
YLabel = 'E (Pa)';
F{3} = animateCurves(8,2,S3,E,S3(1,:),E(1,:),XLabel,YLabel,fontsize,fontweight,...
    linewidth,marker,markersize,colors);
titles{3} = 'stiffness vs strain - original data';

%% Plot 9 - MvsH Movie - Interpoloated Data

XLabel = 'H (A/m)';
YLabel = 'M (A/m)';
F{4} = animateCurves(9,1,H3interp,M3interp,H3interp(:,end),M3interp(:,end),XLabel,YLabel,fontsize,fontweight,...
    linewidth,marker,markersize,colors);
titles{4} = ['M vs H - interpolated data'];

%% Plot 10 - stress vs strain Movie - Interpoloated Data

XLabel = '\epsilon ()';
YLabel = '\sigma (Pa)';
F{5} = animateCurves(10,2,S3interp,Tel3interp,S3interp(1,:),Tel3interp(1,:),XLabel,YLabel,fontsize,fontweight,...
    linewidth,marker,markersize,colors);
titles{5} = ['stress vs strain - interpolated data'];

%% Plot 11 - stiffness vs strain Movie - Interpoloated Data

XLabel = '\epsilon ()';
YLabel = 'E (Pa)';
F{6} = animateCurves(11,2,S3interp,Einterp,S3interp(1,:),Einterp(1,:),XLabel,YLabel,fontsize,fontweight,...
    linewidth,marker,markersize,colors);
titles{6} = ['stiffness vs strain - interpolated data'];

%% Save movie frames
% save('movieFrames','F');

%% Save / print figures
%example of how to save figures / print as .png files with 300 dpi 
figure(1)
print('Images\Image 1','-dpng','-r300');
saveas(gcf, 'Images\Figure 1','fig');

%% Write movies
switch create_movies
    case 1
        for i = 1:numel(F)  %number of movies to make
            fname = ['Movies\',titles{i},'.avi'];
            writerObj = VideoWriter(fname);
            nFrames = numel(F{i});
            if nFrames > 0
                writerObj.FrameRate = nFrames/duration;
                writerObj.Quality = 95;
                open(writerObj)
                for j = 1:numel(F{i})
                    writeVideo(writerObj,F{i}(j));
                end
                close(writerObj)
            end
        end
end

disp('done')

end

%% Subfunctions

%% Numerical Derivatives
function [Fx] = numDiv(X,F,dim)

%pre-allocate derivative
Fx = zeros(size(X));

%use central difference in interior region
switch dim
    case 1
        dF = F(3:end,:) - F(2:end-1,:);
        dX = X(3:end,:) - X(2:end-1,:);
        Fx(2:end-1,:) = dF./dX;
    case 2
        dF = F(:,3:end) - F(:,2:end-1);
        dX = X(:,3:end) - X(:,2:end-1);
        Fx(:,2:end-1) = dF./dX;
end


%use one-sided difference at edges (F(index2) - F(index1))
switch dim
    case 1
        bottom1 = sub2ind(size(X), size(X,1)*ones(1,size(X,2)), 1:size(X,2));
        bottom2 = sub2ind(size(X), (size(X,1)-1)*ones(1,size(X,2)), 1:size(X,2));
        top1 = sub2ind(size(X), 2*ones(1,size(X,2)), 1:size(X,2));
        top2 = sub2ind(size(X),   ones(1,size(X,2)), 1:size(X,2));
        Fx(1,:) = (F(top2)-F(top1))./(X(top2)-X(top1));
        Fx(end,:) = (F(bottom2)-F(bottom1))./(X(bottom2)-X(bottom1));
    case 2
        left1 = sub2ind(size(X), 1:size(X,1),ones(1,size(X,1)));
        left2 = sub2ind(size(X), 1:size(X,1),2*ones(1,size(X,1)));
        right1 = sub2ind(size(X), 1:size(X,1),(size(X,2)-1)*ones(1,size(X,1)));
        right2 = sub2ind(size(X), 1:size(X,1),(size(X,2))*ones(1,size(X,1)));
        Fx(:,1) = (F(left2)-F(left1))./(X(left2)-X(left1));
        Fx(:,end) = (F(right2)-F(right1))./(X(right2)-X(right1));
end

%ex:: temp = zeros(size(X)), temp(left1,left2...)=1, mesh(temp)
% left1 = X==x(1);
% left2 = X==x(2);
% right1 = X==x(end-1);
% right2 = X==x(end);
% bottom1 = F == f(end);
% bottom2 = F == f(end-1);
% top1 = F == f(2);
% top2 = F == f(1);

end

%% include axis labels in movie
function rect = getRegion

ax = gca;
ax.Units = 'pixels';
pos = ax.Position;
ti = ax.TightInset;
rect = [-ti(1), -ti(2), pos(3)+ti(1)+ti(3), pos(4)+ti(2)+ti(4)];

end

%% animation function
function [F, hax, h, href] = animateCurves(figNum,dim,X,Y,X0,Y0,XLabel,YLabel,...
    fontsize,fontweight,linewidth,marker,markersize,colors)

figure(figNum);
clf
hax = axes;
hax.XLabel.String = XLabel;
hax.YLabel.String = YLabel;
hax.FontSize = fontsize;
hax.FontWeight = fontweight;
grid on
hax.XLim = [min(X(:)) max(X(:))];
hax.YLim = [min(Y(:)) max(Y(:))];

h = line(0,0,'LineWidth',linewidth,'Marker',marker,'MarkerSize',markersize,'Color',colors(1,:));
hold on
href = line(X0,Y0,'LineWidth',linewidth,'Marker',marker,'MarkerSize',markersize,'Color',colors(2,:));

switch dim
    case 1
        num = size(X,2);
    case 2
        num = size(X,1);
end

for i = 1:num
    
    switch dim
        case 1
            h.XData = X(:,num+1-i);
            h.YData = Y(:,num+1-i);
        case 2
            h.XData = X(i,:);
            h.YData = Y(i,:);
    end
    drawnow
    F(i) = getframe(gca,getRegion);
    
end

end


