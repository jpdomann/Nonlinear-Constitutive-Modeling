function [ ] = centerAxis( varargin )
%CENTERAXIS Summary of this function goes here
%   Detailed explanation goes here

if nargin==1
    hax = varargin{1};
else 
    hax = gca;
end

%axis limits
x = hax.XLim;
y = hax.YLim;
z = hax.ZLim;

% Max limit
X = max(abs(x));
Y = max(abs(y));
Z = max(abs(z));

%Set new symmetric limits
hax.XLim = [-X X];
hax.YLim = [-Y Y];
hax.ZLim = [-Z Z];

end

