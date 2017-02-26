function [ B1,B2 ] = calc_B( E,nu,S100,S111 )
%CALC_B Summary of this function goes here
%   Detailed explanation goes here


C11 = (1-nu)./((1+nu).*(1-2.*nu)).*E;
C12 = (nu)./((1+nu).*(1-2.*nu)).*E;
C44 = (1-2.*nu)./(2.*(1+nu).*(1-2.*nu)).*E;

%Magnetoelastic Coupling Coefficient
B1 = 3/2.*S100.*(C12-C11);
B2 = -3.*S111.*C44;


end

