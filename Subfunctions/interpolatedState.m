function [ output ] = interpolatedState( h1,h3,t1,t2,t3,t5,GRID,name,direction )
%INTERPOLATEDSTATE Uses a set of stored data points to interpolate the
%given state and return the desired argument. The h_i, and t_i inputs are
%the state vectors (nx1) or (1xn). The NAME input is the desired output
%property ('M' or 'S'). DIRECTION is the index of the desired direction
%('1', '2', or '3'). Lastly, the CRYSTAL input is the desired
%crystal orientation. Note that the crystal orientation selected must
%already have data stored in the 'Data Sets\Single Crystal' folder

%% Parse Grid Data
parseStructure(GRID);

%% Ensure all input elements have same matrix size
% originalInput = {h1,h3,t1,t2,t3,t5}';
% sameSizes = sameSize(originalInput);
% 
% % adjust inputs
% h1 = sameSizes{1};  h3 = sameSizes{3};
% t1 = sameSizes{4}; t2 = sameSizes{5}; t3 = sameSizes{6}; t5 = sameSizes{8};
% % h2 = sameSizes{2};t4 = sameSizes{7};t6 = sameSizes{9};

%% Reshape Refference Arrays (eliminate size 1 dimensions)
%size of field grid
a = size(H1);
dim = a(a>1);

%eliminate singleton dimensions for following interpolation (can't
%interpolate along a dimension that has only one point...)
H1 = reshape(H1,dim);
% H2 = reshape(H2,dim);
H3 = reshape(H3,dim);

T1 = reshape(T1,dim);
T2 = reshape(T2,dim);
T3 = reshape(T3,dim);
% T4 = reshape(T4,dim);
T5 = reshape(T5,dim);
% T6 = reshape(T6,dim);

target = [name,direction];
eval([target,'=reshape(',target,',dim);']);
% M1 = reshape(M1,dim);
% M2 = reshape(M2,dim);
% M3 = reshape(M3,dim);
% 
% S1 = reshape(S1,dim);
% S2 = reshape(S2,dim);
% S3 = reshape(S3,dim);
% S4 = reshape(S4,dim);
% S5 = reshape(S5,dim);
% S6 = reshape(S6,dim);

%% Interpolate
%determine name of function to interpolate
output = eval(['interpn(H1,H3,T1,T2,T3,T5,',target,',h1,h3,t1,t2,t3,t5,''linear'',0);']);
% output = eval(['interpn(H3,T3,',evalName,',h3,t3,''linear'',0);']);
% test = interpn(H1,H3,T1,T2,T3,T5,M1,h1,h3,t1,t2,t3,t5,'linear',0);

end

