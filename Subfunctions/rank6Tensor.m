function [ U ] = rank6Tensor( K, alpha )
%RANK4TENSOR Summary of this function goes here
%   Detailed explanation goes here

%Initialize output
U = 0;

%Loop to form product
for i = 1:3
    for j = 1:3 
        for k = 1:3
            for l = 1:3 
                for m = 1:3
                    for n = 1:3
                        U = U + K(i,j,k,l,m,n).*...
                            alpha(i).*alpha(j).*alpha(k).*alpha(l).*...
                            alpha(m).*alpha(n);
                    end
                end
            end
        end
    end
end

end

