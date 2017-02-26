function [ TM ] = transformationMatrix( a, b )
%TRANSFORMMATRIX generate the transformation matrix that rotates vector a
%into the same direction as vector b
%  See: http://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d

%Initial vector direction - a
%New vector direction - b

%normalized direction
a = a(:)./sqrt(dot(a,a));
b = b(:)./sqrt(dot(b,b));

v = cross(a,b);
if a==b
    TM = eye(3);
elseif a == -b
    TM = -eye(3);
    if all(sign(a).*a ~= [1; 0; 0]) | all(sign(b).*b ~= [1; 0; 0])
        TM(1,1) = 1; %rotate about x axis
    elseif all(sign(a).*a ~= [0; 1; 0]) | all(sign(b).*b ~= [0; 1; 0])
        TM(2,2) = 1; %rotate about y axis
    else
        TM(3,3) = 1; %rotate about z axis
    end
else
    s = sqrt(dot(v,v)); %sin of angle
    c = dot(a,b);       %cos of angle
    vx = [0 -v(3) v(2);...
        v(3) 0 -v(1);...
        -v(2) v(1) 0];      %skew symmetric cross product matrix

    %Transformation matrix
    TM = eye(3) + vx + vx^2 * (1-c)/s^2;
end

% %Alternate formulation
% if a==b
%     TM = eye(3);
% elseif a==-b
%     TM = -eye(3);
%     TM(2,2) = 1; %rotate about y axis (x=-x)
% else
%     G = [dot(a,b)           -norm(cross(a,b))   0;
%         norm(cross(a,b))  dot(a,b)            0;
%         0                 0                   1];
%     Fi = [ a, (b-dot(a,b)*a)/norm(b-dot(a,b)*a), cross(b,a) ];
%     
%     TM = Fi*G*inv(Fi);
% end

end

