%Ni Data - From Magnetostrictive Materials Spreadsheet / OHandley

%Magnetic properties
options.Ms = 485e3;            %(A/m) - Saturation Magnetization
% options.Lambda100 = -58e-6;     %strain - magnetostriction
options.crystal = 'cubic';      %crystaline structure
options.K1 = -4.5e3;              %J/m^3 - Crystaline anisotropy
options.K2 = -2.3e3;             %J/m^3 - Crystaline anisotropy
options.S100 = -46e-6;          %strain - saturation magnetostriction
options.S111 = -25e-6;          %strain - saturation magnetostriction

% %Mechanical properties
E = 170e9;                      %Pa - Isotropic Young's Modulus
nu = 0.5-1e-6;                  %unitless - Poisson's Ratio (just shy of .5 for volume conserving magnetostriction)

%Stiffness components based on isotropic properties
options.C11 = (1-nu)./((1+nu).*(1-2*nu)).*E;
options.C12 = (nu)./((1+nu).*(1-2*nu)).*E;
options.C44 = (1-2*nu)./(2*(1+nu).*(1-2*nu)).*E;

%Magnetoelastic Coupling Coefficient
options.B1 = 3/2*options.S100*(options.C12-options.C11);
options.B2 = -3*options.S111*options.C44;

%reference values from OHandley
% options.B1 = 6.2e6;             %N/m^2
% options.B2 = 4.3e6;             %N/m^2

%Phenomenological 'Thermal' Energy
options.Omega = 500;            %J/m^3

