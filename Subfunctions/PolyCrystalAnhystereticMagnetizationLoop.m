function [ M1,s1 ] = PolyCrystalAnhystereticMagnetizationLoop( H1,T1,options, hplot)
%POLYCRYSTALANHYSTERETICMAGNETIZATIONLOOP Summary of this function goes here
%   Detailed explanation goes here

%% Input options
parseStructure(options)
TM = options.TM;

%initialize data arrays
M1 = zeros(size(H1));
s1 = M1;

t2(1:nPoints) = 0;
options.t2 = t2;

%% Run loops
%stress tensor rotations
disp(['Generating rotated stress tensors: ',datestr(datetime)])
p = ProgressBar(nPoints);
%initialize arrays
T_rot = zeros(6,nPoints);
parfor i = 1:nPoints
    %rotate stress tensor    
    t = zeros(3);
    t(1,1) = T1(i);
    t_rot = transformTensor(t,TM);
    T_rot(:,i) = [t_rot(1,1) t_rot(2,2) t_rot(3,3) t_rot(2,3) t_rot(1,3) t_rot(1,2)]';
    p.progress; % Also percent = p.progress;
end
p.stop; %stop progress bar

% Run magnetization / magnetostriction loops
disp(['Starting Magnetization \ Magnetostriction Calculation: ',datestr(datetime)])
p = ProgressBar(nPoints);
switch loop
    case 'serial'
        for i = 1:nPoints            
            
            %Magnetization
            [M1(i),~,~,options,hplot] = anhystereticMagnetization(H1(i),0,0,...
                T_rot(1,i),T_rot(2,i),T_rot(3,i),T_rot(4,i),T_rot(5,i),T_rot(6,i),options,i,hplot);            
            % Magnetostriction
            [s1(i),~,~,~,~,~] = anhystereticMagnetostriction(H1(i),0,0,...
                T_rot(1,i),T_rot(2,i),T_rot(3,i),T_rot(4,i),T_rot(5,i),T_rot(6,i),options,i,hplot);
            
            p.progress; % Also percent = p.progress;
        end
    case 'parallel'
        %ensure specific options are turned off (no plotting)
        options.DiagnosticPlot = false;
        options.iterations = false;
        
        %start parallel pool
        pool = gcp;        
        parfor i = 1:nPoints  
            
            %Magnetization            
            [M1(i),~,~] = anhystereticMagnetization(H1(i),0,0,...
                T_rot(1,i),T_rot(2,i),T_rot(3,i),T_rot(4,i),T_rot(5,i),T_rot(6,i),options,i);        
            % Magnetostriction
            [s1(i),~,~,~,~,~] = anhystereticMagnetostriction(H1(i),0,0,...
                T_rot(1,i),T_rot(2,i),T_rot(3,i),T_rot(4,i),T_rot(5,i),T_rot(6,i),options,i);
            
            p.progress; % Also percent = p.progress;
        end        
        
end
p.stop; %stop progress bar

disp(['Finished Magnetization \ Magnetostriction Calculation: ',datestr(datetime)])
end

