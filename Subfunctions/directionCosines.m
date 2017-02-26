function [ alpha1,alpha2,alpha3,alpha1_rot,alpha2_rot,alpha3_rot ] =...
    directionCosines( TM )
%DIRECTIONCOSINES Summary of this function goes here
%   Detailed explanation goes here

%initial direction cosines
alpha1 = @(theta,phi) sin(theta).*cos(phi);
alpha2 = @(theta,phi) sin(theta).*sin(phi);
alpha3 = @(theta,phi) cos(theta);

%rotated based on input transformation matrix (TM)
alpha1_rot = @(theta,phi) TM(1,1)*alpha1(theta,phi) + TM(1,2)*alpha2(theta,phi)+ TM(1,3)*alpha3(theta,phi);
alpha2_rot = @(theta,phi) TM(2,1)*alpha1(theta,phi) + TM(2,2)*alpha2(theta,phi)+ TM(2,3)*alpha3(theta,phi);
alpha3_rot = @(theta,phi) TM(3,1)*alpha1(theta,phi) + TM(3,2)*alpha2(theta,phi)+ TM(3,3)*alpha3(theta,phi);


end

