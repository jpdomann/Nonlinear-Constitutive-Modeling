function [M_an] = M_anhysteretic(H,H_dir_in, params, options)
%M_ANHYSTERETIC is used to calculate the anhysteretic magnetization curve
%in the specified direction. This function primarily returns the change in
%magnetization during an incremental 'time' step for an ode solver. The
%curve starts from zero magnetization, zero effective field, and proceeds
%until saturation has been reached (at least twice the coercive field).
%Note that even though time is used as a parameter, no dynamic effects are
%currently used
%
%   use:
%           ODE solver operates on dM/dt = (dM/dH)_anhys * (dH/dt)
%   inputs:
%           t - time (ranges from 0 to 1)
%             - provided by the ODE solver
%           M - magnetization vector
%             - provided by the ODE solver
%           Dir - direction of applied field
%   outputs:
%           dMdt - incremental change in magnetization during 'time' step
%           H_an - magnitude of ma


%% Input State
global TH PH mu0 Kb
%Load parameters
parseStructure(params)
parseStructure(options)

if norm(H)==0
    H_dir = H_dir_in;
else
    H_dir = H./norm(H);
end

%% Energy Terms

[phi_H,theta_H , ~] = cart2sph(H_dir(1),H_dir(2),H_dir(3));
theta_H = pi/2 - theta_H;

%E1 and E2 Energy functions used in anhystertic magnetization integrals
switch crystal
    case 'uniaxial'
        E_mca = @(theta,phi) K1.*sin(theta).^2 +K2.*sin(theta).^4 + K4.*sin(theta).^6.*cos(phi)  ;
    case 'cubic'
        E_mca = @(theta,phi) K1.*(sin(theta).^4.*cos(phi).^2.*sin(phi).^2 + ...
            sin(theta).^2.*cos(theta).^2) +...
            K2.*(sin(theta).^4.*cos(theta).^2.*cos(phi).^2.*sin(phi).^2);
end
m0 = mu0*Ms/N;
E_H = @(theta,phi) -m0.*norm(H).*(sin(theta).*cos(phi).*sin(theta_H).*cos(phi_H)+...
    sin(theta).*sin(phi).*sin(theta_H).*sin(phi_H) + cos(theta).*cos(theta_H) );

%Normalized Energy (w.r.t. Kb*T)
E =@(theta,phi) (E_H(theta,phi)./(Kb*T) + E_mca(theta,phi)./(Ms.*a.*mu0));     %Dimensionless

%% Minimum Energy
%Check for the minimum energy value over the angular domain
%TH an PH are specified as global variables in the calling function
E_eval = E(TH,PH);
[E_min_val,Ind] = min(E_eval(:));
th_min = TH(Ind);
ph_min = PH(Ind);

%Shift the energy surface so that it's minimum value is zero
if E_min_val < 0
    E = @(theta,phi) E(theta,phi)- E_min_val;
end

%% Statistical Distribution Function
if exist('distribution','var')
    %Select statistical distribution
    switch distribution
        case 'boltzmann'
            dist =@(theta,phi) exp(-E(theta,phi));
        case 'fermi'
            dist =@(theta,phi) 1./( exp(-E(theta,phi)) + 1);
        case 'bose'
            dist =@(theta,phi) 1./( exp(-E(theta,phi)) - 1);
        otherwise
            %if misspelled, assume boltzmann
            dist =@(theta,phi) exp(-E(theta,phi));
    end
else
    %if nothing entered, assume boltzmann
    dist =@(theta,phi) exp(-E(theta,phi));
end

%% plot
% if plotFlag
%     figure(1)
%     subplot(2,2,3)
%     hold off
%     surfc(TH,PH,E(TH,PH)) ;
%     xlim([0 pi])
%     ylim([0 2*pi])
%     title('(E_H(\theta,\phi)/(Kb T) + E_{MCA}(\theta,\phi)/(Ms a \mu_0))')
%     h = gca;
%     h1 = findobj(h.Children,'type','surface');
%     h1.EdgeAlpha = .1;
%
%     subplot(2,2,4)
%     hold off
%     h = surf(TH,PH,dist(TH,PH)) ;
%     xlim([0 pi])
%     ylim([0 2*pi])
% %     axis([0 pi -pi pi 0 1])
%     title('(exp(-E(\theta,\phi) - E\_min\_val)')
%     h.EdgeAlpha=.1;
%     pause(.01)
% end

%% Integrands for finding the Anhysteretic Magnetization
% A = @(theta,phi) sin(theta).*cos(phi).*sin(theta_O).*cos(phi_O) + ...
%     sin(theta).*sin(phi).*sin(theta_O).*sin(phi_O) + ...
%     cos(theta).*cos(theta_O);
% f =@(theta,phi) dist(theta,phi).*A(theta,phi).*sin(theta);
Ax = @(theta,phi) sin(theta).*cos(phi);
Ay = @(theta,phi) sin(theta).*sin(phi);
Az = @(theta,phi) cos(theta);

fx =@(theta,phi) dist(theta,phi).*Ax(theta,phi).*sin(theta);
fy =@(theta,phi) dist(theta,phi).*Ay(theta,phi).*sin(theta);
fz =@(theta,phi) dist(theta,phi).*Az(theta,phi).*sin(theta);

g =@(theta,phi) dist(theta,phi).*sin(theta);

%% Integrate to obtain the Anhysteretic Magnetization
%Double integral
% F = integral2(f,0,pi,0,2*pi,'AbsTol',1e-9,'RelTol',1e-6,'Method','iterated');
Alim = 1e-3;
Rlim = 1e-3;
method = 'iterated';

% tic
Fx = integral2(fx,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim,'Method',method);
Fy = integral2(fy,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim,'Method',method);
Fz = integral2(fz,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim,'Method',method);
G = integral2(g,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim,'Method',method);
% toc

% tic
% Fx = quad2d(fx,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim);
% Fy = quad2d(fy,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim);
% Fz = quad2d(fz,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim);
% G = quad2d(g,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim);
% toc

% tic
% Fx = sum(sum(fx(TH,PH)))*TH(1,2)^(2);
% Fy = sum(sum(fy(TH,PH)))*TH(1,2)^(2);
% Fz = sum(sum(fz(TH,PH)))*TH(1,2)^(2);
% G = sum(sum(g(TH,PH)))*TH(1,2)^(2);
% toc

%% Calculate Anhysteretic Anisotropic Magnetization / Susceptibility
if G==0
    %set anhysteretic anisotropic M to zero (don't divide by zero)
    M_an=[0;0;0];
else
    ManX = Ms.*Fx./G;
    ManY = Ms.*Fy./G;
    ManZ = Ms.*Fz./G;
    
    %     ManX = Ms.*Fxtemp./Gtemp;
    %     ManY = Ms.*Fytemp./Gtemp;
    %     ManZ = Ms.*Fztemp./Gtemp;
    
    M_an = [ManX;ManY;ManZ];
end


end

