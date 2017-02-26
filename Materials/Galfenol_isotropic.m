%Polycrystalline properties
% options.E = 75e9;                       %GPa - modulus of elasticity
% options.permeability_r = 200;           %unitless - relative permeability
% options.permitivity_r = 1;              %unitless - relative permitivity
% options.mu = options.permeability_r * options.permeability_0;
% options.permitivity = options.permitivity_r * options.permitivity_0;

%Magnetic properties - Fe84 Ga16 - Datta2009 - phd thesis
options.Ms = 1456e3;            %(A/m) - Saturation Magnetization
options.Lambda100 = 250e-6;     %strain - satruation magnetostriction
options.Lambda111 = 250e-6;     %strain - satruation magnetostriction
options.crystal = 'cubic';      %crystaline structure
options.K1 = 0;                 %J/m^3 - Crystaline anisotropy
options.K2 = 0;                 %J/m^3 - Crystaline anisotropy
% options.S100 = 250e-6;          %strain - saturation magnetostriction
% options.S111 = 250e-6;          %strain - saturation magnetostriction

%Mechanical properties of Fe81.3 Ga18.7 Polycrystalline - Etrema data
E = 75e9;                       % Pa - Young's Modulus
nu = 0.3;                       %Popisson's Ratio
lambda = E / ((1+nu)*(1-2*nu)); %Pa - Lame parameter
C11 = lambda *(1-nu);   %Pa - stiffness
C12 = lambda *nu;       %Pa - stiffness
C44 = lambda *(1-2*nu); %Pa - stiffness
options.C11 = C11; options.C12 = C12; options.C44 = C44;
options.stiffness=[ C11,   C12,    C12,    0,  0,  0;
            C12,    C11,    C12,    0,  0,  0;
            C12,    C12,    C11,    0,  0,  0;
            0,      0,      0,      C44,0,  0;
            0,      0,      0,      0,  C44,  0;
            0,      0,      0,      0,  0,  C44];
options.compliance = options.stiffness^-1;

%Magnetoelastic Coupling Coefficient
options.B1 = -3/2*options.Lambda100*(options.C11-options.C12);
options.B2 = -3*options.Lambda111*options.C44;
iso_check = 2.*options.B1 == options.B2;

%Phenomenological 'Thermal' Energy 
%this is from the literature (Dapino's group)
options.Omega = 600;            %J/m^3