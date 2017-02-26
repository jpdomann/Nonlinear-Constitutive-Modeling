function [ varargout ] = averageProperties( U, Omega,H,S, Q, Qmax, options )
%AVERAGEPROPERTIES Summary of this function goes here
%   Detailed explanation goes here

theta = options.theta;
phi = options.phi;
THETA = options.THETA;
PHI = options.PHI;

%energy ratio
ER = @(theta,phi) -U(theta,phi,H,S)./Omega;

%max probability density so integral can be calculated.
%if probability density was uniform for theta,phi - the max value that can
%be integrated is:
Qmax = max([Qmax,1]);
maxAllow = realmax/(4*pi*Qmax)*.99;
while max(max(ER(THETA,PHI))) > log(maxAllow);
    divisor = min([10,max(max(ER(THETA,PHI))) / (.99*log(maxAllow))]) ;
    ER = @(theta,phi) ER(theta,phi)/(divisor);
end

%probability function
p = @(theta,phi) exp(ER(theta,phi));

%Integration options
Alim = 1e-6;
Rlim = 1e-6;
method = 'tiled';
% method = 'iterated';

% tic
%integrand - denominator
g = @(theta,phi) p(theta,phi).*(sin(theta));
%Integrate - denominator
% G = integral2(g,0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim,'Method',method);
G = trapz(phi,trapz(theta,g(THETA,PHI)));

%Loop for numerator of average property
Q_avg = cell(1,nargout);    %initialize storage cell

for i = 1:numel(Q)
    %integrand - numerator
    f{i} = @(theta,phi) Q{i}(theta,phi).*p(theta,phi).*(sin(theta));
    %Integrate
    %F{i} = integral2(f{i},0,pi,0,2*pi,'AbsTol',Alim,'RelTol',Rlim,'Method',method);
    F{i} = trapz(phi,trapz(theta,f{i}(THETA,PHI)));
    
    %Average property
    if G==0
        %set anhysteretic anisotropic M to zero (don't divide by zero)
        Q_avg{i}  = zeros(size(F{i}));
    else
        Q_avg{i}  = F{i}./G;
    end
    
end

%Store average property in output array
varargout = cell(1,nargout);
for i = 1:numel(Q_avg)
    varargout{i} = Q_avg{i};
end

end

