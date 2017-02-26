function [ M1,M2,M3,...
    Tel1,Tel2,Tel3,Tel4,Tel5,Tel6,...
    Tm1,Tm2,Tm3,Tm4,Tm5,Tm6,...    
    Sm1,Sm2,Sm3,Sm4,Sm5,Sm6] = ...
    AnhystereticMagnetizationLoop( H1,H2,H3,...
    S1,S2,S3,S4,S5,S6,options, hplot)
%ANHYSTERETICMAGNETIZATIONLOOP Summary of this function goes here
%   Detailed explanation goes here

%% Input options
parseStructure(options)
TM = options.TM;

%initialize output data arrays
M1 = zeros(size(H1));M2 = M1;M3 = M1;
Tel1 = M1;Tel2 = Tel1;Tel3 = Tel1;Tel4 = Tel1;Tel5 = Tel1;Tel6 = Tel1;
Tm1 = M1;Tm2 = Tm1;Tm3 = Tm1;Tm4 = Tm1;Tm5 = Tm1;Tm6 = Tm1;
Sm1 = M1;Sm2 = Sm1;Sm3 = Sm1;Sm4 = Sm1;Sm5 = Sm1;Sm6 = Sm1;

stop_time(1:nPoints) = 0;  %lookup purpose before renaming
options.stop_time = stop_time;


%% Run loops
disp(['Starting Magnetization Calculation: ',datestr(datetime)])
p = ProgressBar(nPoints);
switch loop
    case 'serial'
        for i = 1:nPoints 
            %rotate strain tensor
            s = [S1(i),S6(i),S5(i);...
                S6(i) S2(i) S4(i);...
                S5(i) S4(i) S3(i)];
            s_rot = transformTensor(s,TM);
            S_rot = [s_rot(1,1) s_rot(2,2) s_rot(3,3) s_rot(2,3) s_rot(1,3) s_rot(1,2)]';
            %Magnetization
            [M1(i),M2(i),M3(i),options,hplot] = anhystereticMagnetization(H1(i),H2(i),H3(i),...
                S_rot(1),S_rot(2),S_rot(3),S_rot(4),S_rot(5),S_rot(6),options,i,hplot);            
            % Magnetostriction
            [Tel1(i),Tel2(i),Tel3(i),Tel4(i),Tel5(i),Tel6(i),...   %elastic stress
             Tm1(i),Tm2(i),Tm3(i),Tm4(i),Tm5(i),Tm6(i),...          %magnetostrictive stress
               Sm1(i),Sm2(i),Sm3(i),Sm4(i),Sm5(i),Sm6(i) ] = ...    %magnetostrictive strain
               anhystereticMagnetostriction(H1(i),H2(i),H3(i),...
                S_rot(1),S_rot(2),S_rot(3),S_rot(4),S_rot(5),S_rot(6),options,i,hplot);
           
            p.progress; % Also percent = p.progress;
        end
    case 'parallel'
        %ensure specific options are turned off (no plotting)
        options.DiagnosticPlot = false;
        options.iterations = false;
        
        %start parallel pool
        pool = gcp;        
        parfor i = 1:nPoints  
            %rotate strain tensor
            s = [S1(i),S6(i),S5(i);...
                S6(i) S2(i) S4(i);...
                S5(i) S4(i) S3(i)];
            s_rot = transformTensor(s,TM);
            S_rot = [s_rot(1,1) s_rot(2,2) s_rot(3,3) s_rot(2,3) s_rot(1,3) s_rot(1,2)]';
            
            %Magnetization            
            [M1(i),M2(i),M3(i)] = anhystereticMagnetization(H1(i),H2(i),H3(i),...
                S_rot(1),S_rot(2),S_rot(3),S_rot(4),S_rot(5),S_rot(6),options,i);        
            % Magnetostriction             
             [Tel1(i),Tel2(i),Tel3(i),Tel4(i),Tel5(i),Tel6(i),...   %elastic stress
             Tm1(i),Tm2(i),Tm3(i),Tm4(i),Tm5(i),Tm6(i),...          %magnetostrictive stress
               Sm1(i),Sm2(i),Sm3(i),Sm4(i),Sm5(i),Sm6(i) ] = ...    %magnetostrictive strain
               anhystereticMagnetostriction(H1(i),H2(i),H3(i),...
                S_rot(1),S_rot(2),S_rot(3),S_rot(4),S_rot(5),S_rot(6),options,i);
            
            p.progress; % Also percent = p.progress;
        end        
        
end
p.stop; %stop progress bar

disp(['Finished Magnetization Calculation: ',datestr(datetime)])
end

