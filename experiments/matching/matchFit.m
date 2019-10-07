function [error] = matchFit(x, expressMethod,target,varargin)
%shapeMatch - returns area of difference of two polygons
%
% Syntax:  [error] = matchFit(x, expressMethod,target,varargin)
%
% Inputs:
%    x             - parameters for single shape
%    expressMethod - function which converts 'x' parameterization to x,y
%    coordsinates
%    target        - target polygon
%
% Outputs:
%    error - MSE as squared distance of closest points in x to target
%

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Oct 2019; Last revision: 01-Oct-2019

%------------- BEGIN CODE --------------
if nargin > 3
    d = varargin{1};
else
    err('Domain struct missing');
end

phenotype = feval(expressMethod,x',d.base);

Idx = knnsearch(phenotype.vertices',target);

error = immse(phenotype.vertices(:,Idx)',target);

%error = immse(phenotype.vertices,target');



%------------- END OF CODE --------------