function [  ] = parseStructure( S,varargin )
%PARSESTRUCTURE Takes an input structure, and converts it to variables
%within the caller workspace

fieldNames = fieldnames(S);
for iField = 1:length(fieldNames)
    assignin('caller',fieldNames{iField},S.(fieldNames{iField}));
end

end

