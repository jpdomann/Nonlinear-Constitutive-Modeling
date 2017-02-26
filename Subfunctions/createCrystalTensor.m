function [ varargout ] = createCrystalTensor( K_vals, crystal )
%CREATECRYSTALTENSOR convert the analytical equations from chikazumi into
%tensor form. This will allow the tensor properties to be rotated into
%arbitrary coordinate systems

%return K# values
for i = 1:numel(K_vals)
    eval(['K',num2str(i),'=K_vals{i};'])
end

%create tensors
switch crystal
    case 'uniaxial'

    case 'cubic'
        %rank 4 elements K1(a1^2*a2^2 + a1^2*a3^2 + a2^2*a3^2) = K_{ijkl}*ai*aj*ak*al
        k1 = zeros(3,3,3,3);
        inds1 = unique(perms([1,1,2,2]),'rows');
        inds2 = unique(perms([1,1,3,3]),'rows');
        inds3 = unique(perms([2,2,3,3]),'rows');
        ind1 = zeros(1,size(inds1,1));
        ind2 = ind1;
        ind3 = ind1;
        for i = 1:size(inds1,1)
            ind1(i) = sub2ind(size(k1),inds1(i,1),inds1(i,2),inds1(i,3),inds1(i,4));           
            ind2(i) = sub2ind(size(k1),inds2(i,1),inds2(i,2),inds2(i,3),inds2(i,4));            
            ind3(i) = sub2ind(size(k1),inds3(i,1),inds3(i,2),inds3(i,3),inds3(i,4));
        end
        ind = [ind1(:); ind2(:); ind3(:)];
        k1(ind) = K1/numel(ind1);


        
        %rank 6 elements K2(a1^2*a2^2*a3^2) = K_{ijklmn}*ai*aj*ak*al*am*an
        k2 = zeros(3,3,3,3,3,3);
        inds1 = unique(perms([1,1,2,2,3,3]),'rows');
        ind1 = zeros(1,size(inds1,1));
        for i = 1:size(inds1,1)
           ind1(i) =  sub2ind(size(k2),inds1(i,1),inds1(i,2),inds1(i,3),inds1(i,4),inds1(i,5),inds1(i,6));    
        end
        k2(ind1) = K2/numel(ind1);
end

%find all 'k' variables and store in variable sized output
k = whos('k*');
varargout = cell(1,numel(k));
for i =1:numel(k)
   varargout{i} = eval(k(i).name);
end

end

