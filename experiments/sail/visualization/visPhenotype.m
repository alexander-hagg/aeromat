function h = visPhenotype(phenotypes,varargin)
%VISPHENOTYPES Summary of this function goes here
%   Detailed explanation goes here
colors = 'k';
positioning = zeros(1,2);
hold off;
if nargin > 1; controlPts = varargin{1}; end
if nargin > 2;  positioning = varargin{2}; end
if nargin > 3; colors = varargin{3}; end
pointSize = 1;
if nargin > 4; pointSize = varargin{4}; end

vX = phenotypes.vertices(1,1:1:end);
vY = phenotypes.vertices(2,1:1:end);
vZ = phenotypes.vertices(3,1:1:end);
if numel(colors)==1
    h = scatter3(vX + positioning(1,1), vY + positioning(1,2), vZ,pointSize,colors,'filled');
else
    h = scatter3(vX + positioning(1,1), vY + positioning(1,2), vZ,pointSize,colors(1,:),'filled');
end
hold on;
% Draw control points
if exist('controlPts','var')
    scatter3(controlPts(1,:),controlPts(2,:),controlPts(3,:),pointSize*16,'k','filled');
end
end

