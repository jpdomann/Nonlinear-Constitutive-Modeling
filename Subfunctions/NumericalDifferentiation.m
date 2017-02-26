function [output] = NumericalDifferentiation(f, x0, delta)
%NUMERICALDIFFERENTIATION  uses central difference formulas to approximate
%the derivatives of a vector valued function by another vector (resulting
%in a rank 2 tensor)

output = zeros(3);
I = eye(3);
for i = 1:3
    for j = i:3
        
        f_plus = f(x0+delta*I(:,j), I(:,j));
        f_minus  = f(x0-delta*I(:,j), I(:,j));
        
        output(i,j) = (f_plus(i)-f_minus(i))./(2*delta);
        
        if i~=j %Force symmetry to reduce number of computations
            output(j,i) = output(i,j);
        end
    end
end


end

