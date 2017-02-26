function [ M,S ] = polyCrystalResponse( M,S, labels)
%POLYCRYSTALRESPONSE Summary of this function goes here
%   Detailed explanation goes here

%% Stored data for Galfenol Volume Fractions
%Galfenol Domain Volume Fractions (Atulasimha2007)
x100 = mean([43.1 7.30 18.2]);
x110 = mean([1.40 0.10 1.20]);
x111 = mean([0.00 0.00 0.00]);
x210 = mean([6.40 31.3 20.5]);
x211 = mean([10.9 0.20 3.20]);
x310 = mean([28.7 49.9 58.8]);
x311 = mean([16.6 23.8 11.5]);

names = whos('x*');
for i = 1:numel(names)
    Xs{i} = names(i).name;
    X(i) = eval(names(i).name);
end
Xlabs = strrep(Xs,'x','');  %labels with stored volume fractions
X = X/sum(X);               %stored volume fractions 

%% Sort based on labels


%% Average Response
varargout = cell(1,nargout);
for i = 1:numel(P100)
    varargout{i} = 2/5*P100{i} + 3/5*P111{i};
end

end

