function [ ] = returnVariables( A )
%RETURNVARIABLES Summary of this function goes here
%   Detailed explanation goes here


if isstruct(A) 
    parseStructure(A);
elseif iscell(A)
    parseCell(A);
end

end

