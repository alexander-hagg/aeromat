function h = visPhenotypes(phenotypes,positioning,varargin)
%VISPHENOTYPES Summary of this function goes here
%   Detailed explanation goes here
colors = 'k';
if nargin > 2; colors = varargin{1}; end
pointSize = 4;
if nargin > 3; pointSize = varargin{2}; end
for i=1:numel(phenotypes)
    vX = phenotypes{i}.vertices(1,1:1:end);
    vY = phenotypes{i}.vertices(2,1:1:end);
    vZ = phenotypes{i}.vertices(3,1:1:end);
    if numel(colors)==1
        h(i) = scatter3(vX + positioning(i,1), vY + positioning(i,2), vZ,pointSize,colors,'filled');
    else
        h(i) = scatter3(vX + positioning(i,1), vY + positioning(i,2), vZ,pointSize,colors(i,:),'filled');
    end
    hold on;
end
end

