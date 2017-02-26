function [ varargout ] = createMagnetoelasticTensor( D_vals, crystal )
%CREATEMAGNETOELASTICTENSOR convert the analytical equations from chikazumi into
%tensor form. This will allow the tensor properties to be rotated into
%arbitrary coordinate systems

%return B# values
for i = 1:numel(D_vals)
    eval(['D',num2str(i),'= D_vals{i};'])
end

%create tensors
switch crystal
    case 'uniaxial'

    case 'cubic'
        %rank 4 elements 
        %B1(S11-S12)(sigma_11*a1^2+sigma_22*a2^2+sigma_33*a3^2-1/3 Tr(sigma))+
        %B2*S44(sigma_12 a1*a2 + sigma_13 a1*a3 + sigma_23 a2*a3) = 
        %D_{ij}sigma_{ij} + D_{ijkl}*sigma_ij*ak*al
        
        %Note: B1(S11-S12) = D1 AND B2*S44 = D2;
        
        d1 = zeros(3,3);
        inds1 = [1 1; 2 2; 3 3];        
        ind1 = zeros(1,size(inds1,1));
        for i = 1:size(inds1,1)
            ind1(i) = sub2ind(size(d1),inds1(i,1),inds1(i,2));           
        end
        d1(ind1) = -D1/numel(ind1);
        
        d2 = zeros(3,3,3,3);
        inds1 = unique(perms([1,1,1,1]),'rows');
        inds2 = unique(perms([2,2,2,2]),'rows');
        inds3 = unique(perms([3,3,3,3]),'rows');
        inds4 = unique(perms([1,1,2,2]),'rows');
        inds5 = unique(perms([1,1,3,3]),'rows');
        inds6 = unique(perms([2,2,3,3]),'rows');
        
        ind1 = zeros(1,size(inds1,1));
        ind2 = ind1;
        ind3 = ind1;
        for i = 1:size(inds1,1)
            ind1(i) = sub2ind(size(d2),inds1(i,1),inds1(i,2),inds1(i,3),inds1(i,4));           
            ind2(i) = sub2ind(size(d2),inds2(i,1),inds2(i,2),inds2(i,3),inds2(i,4));            
            ind3(i) = sub2ind(size(d2),inds3(i,1),inds3(i,2),inds3(i,3),inds3(i,4));
        end
        ind = [ind1(:); ind2(:); ind3(:)];
        d2(ind) = D1/numel(ind1);
        
        ind4 = zeros(1,size(inds4,1));
        ind5 = ind4;
        ind6 = ind4;
       for i = 1:size(inds4,1)
            ind4(i) = sub2ind(size(d2),inds4(i,1),inds4(i,2),inds4(i,3),inds4(i,4));           
            ind5(i) = sub2ind(size(d2),inds5(i,1),inds5(i,2),inds5(i,3),inds5(i,4));            
            ind6(i) = sub2ind(size(d2),inds6(i,1),inds6(i,2),inds6(i,3),inds6(i,4));
        end
        ind = [ind4(:); ind5(:); ind6(:)];
        d2(ind) = D2/numel(ind1);              
end

%find all 'k' variables and store in variable sized output
d = whos('d*');
varargout = cell(1,numel(d));
for i =1:numel(d)
   varargout{i} = eval(d(i).name);
end

end

