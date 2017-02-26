%Polycrystalline properties
% options.E = 75e9;                       %GPa - modulus of elasticity
% options.permeability_r = 200;           %unitless - relative permeability
% options.permitivity_r = 1;              %unitless - relative permitivity
% options.mu = options.permeability_r * options.permeability_0;
% options.permitivity = options.permitivity_r * options.permitivity_0;

%Magnetic properties - Fe84 Ga16 - Datta2009 - phd thesis
options.Ms = 1456e3;            %(A/m) - Saturation Magnetization
options.Lambda100 = 165e-6;     %strain - magnetostriction
options.crystal = 'cubic';      %crystaline structure
options.K1 = 13e3;              %J/m^3 - Crystaline anisotropy
options.K2 = -90e3;             %J/m^3 - Crystaline anisotropy
options.S100 = 164e-6;          %strain - saturation magnetostriction
options.S111 = -13e-6;          %strain - saturation magnetostriction

% %Mechanical properties Fe83 Ga17 - Kellog2003a -
options.C11 = 225e9;            %Pa - stiffness
options.C12 = 181e9;            %Pa - stiffness
options.C44 = 128e9;            %Pa - stiffness

%Mechanical properties Fe81.3 Ga18.7 - Clark - Mechanical properties of..
options.C11 = 196e9;            %Pa - stiffness
options.C12 = 156e9;            %Pa - stiffness
options.C44 = 123e9;            %Pa - stiffness

%Magnetoelastic Coupling Coefficient
options.B1 = 3/2*options.S100*(options.C12-options.C11);
options.B2 = -3*options.S111*options.C44;

%Phenomenological 'Thermal' Energy
options.Omega = 600;            %J/m^3