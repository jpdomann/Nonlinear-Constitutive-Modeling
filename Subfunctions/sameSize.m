function [ output ] = sameSize( input )
%SAMESIZE ensures that any scalar elements of the input cell are converted
%to matrices of the same size as any other matrices in the input cell. If
%any matrices are in input, they must be of the same size, else an error is
%thrown. The method is valid for matrices with up to 9 dimensions.

[s1,s2,s3,s4,s5,s6,s7,s8,s9] = cellfun(@size,input);
sizes = [s1(:),s2(:),s3(:),s4(:),s5(:),s6(:),s7(:),s8(:),s9(:)];

%find all vectors of size 1x1
id1 = sum(sizes == 1,2)==size(sizes,2);
scalars = {input{id1}};
[scal_s1,scal_s2,scal_s3,scal_s4,scal_s5,scal_s6,scal_s7,scal_s8,scal_s9] =...
    cellfun(@size,scalars );

%check if all the inputs were scalars, if not, operate on the input
%matrices

if any(~id1)
    %all other inputs are matrices (or vectors)
    vecs = {input{~id1}};
    %ensure all matrices are the same size
    [vec_s1,vec_s2,vec_s3,vec_s4,vec_s5,vec_s6,vec_s7,vec_s8,vec_s9] =...
        cellfun(@size,vecs );
    
    flag = all(vec_s1 == vec_s1(1)) && all(vec_s2 == vec_s2(1)) && all(vec_s3 == vec_s3(1)) &&...
        all(vec_s4 == vec_s4(1)) && all(vec_s5 == vec_s5(1)) && all(vec_s6 == vec_s6(1)) &&...
        all(vec_s7 == vec_s7(1)) && all(vec_s8 == vec_s8(1)) && all(vec_s9 == vec_s9(1));
    
    if flag
        vec_s1 = vec_s1(1); vec_s2 = vec_s2(1); vec_s3 = vec_s3(1);
        vec_s4 = vec_s4(1); vec_s5 = vec_s5(1); vec_s6 = vec_s6(1);
        vec_s7 = vec_s7(1); vec_s8 = vec_s8(1); vec_s9 = vec_s9(1);
    else
        error('Input matrices must be the same size, or a combination of the matrices with the same size and scalars')
    end
    
    
    %resize scalars to match vector size
    scalars = cellfun(@repmat,...
        scalars,...
        mat2cell(vec_s1*ones(size(scal_s1,1),size(scal_s1,2)),ones(size(scal_s1,1),1),ones(size(scal_s1,2),1) ),...
        mat2cell(vec_s2*ones(size(scal_s2,1),size(scal_s2,2)),ones(size(scal_s2,1),1),ones(size(scal_s2,2),1) ),...
        mat2cell(vec_s3*ones(size(scal_s3,1),size(scal_s3,2)),ones(size(scal_s3,1),1),ones(size(scal_s3,2),1) ),...
        mat2cell(vec_s4*ones(size(scal_s4,1),size(scal_s4,2)),ones(size(scal_s4,1),1),ones(size(scal_s4,2),1) ),...
        mat2cell(vec_s5*ones(size(scal_s5,1),size(scal_s5,2)),ones(size(scal_s5,1),1),ones(size(scal_s5,2),1) ),...
        mat2cell(vec_s6*ones(size(scal_s6,1),size(scal_s6,2)),ones(size(scal_s6,1),1),ones(size(scal_s6,2),1) ),...
        mat2cell(vec_s7*ones(size(scal_s7,1),size(scal_s7,2)),ones(size(scal_s7,1),1),ones(size(scal_s7,2),1) ),...
        mat2cell(vec_s8*ones(size(scal_s8,1),size(scal_s8,2)),ones(size(scal_s8,1),1),ones(size(scal_s8,2),1) ),...
        mat2cell(vec_s9*ones(size(scal_s9,1),size(scal_s9,2)),ones(size(scal_s9,1),1),ones(size(scal_s9,2),1) ),...
        'UniformOutput',false);
    
    
end

%redistribute elemnts to their variable names
ind1 = 1;
ind2 = 1;
output = cell(size(input));
for i = 1:numel(id1)
    switch id1(i)
        case 1
            output{i} = scalars{ind1};
            ind1 = ind1+1;
        case 0
            output{i} = vecs{ind2};
            ind2 = ind2+1;
    end
end

end

