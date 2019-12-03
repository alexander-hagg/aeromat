function [length, maxVertex, minVertex, maxVertexID, minVertexID] = getRelativeLengthY(mirror, d)
%getRelativeLength - Returns relative length of mirror (x/y)
%
% Syntax:  [relativeLength] = getLength(mirror, d)
%
% Inputs:
%    mirrorSubmesh - [Npoints X 3] - X,Y,Z coordinates of each changeable vertex in design
%    d - domain
% Outputs:
%    length - [scalar] - Relative length of mirrorSubmesh (x/y)
%
% Example:
%    d = mirror_Domain; % for point IDs
%    FV = mirror_ffd_Express(0.5 + zeros(1,41), d.FfdP);
%    length = getLength(FV.vertices,d)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: alexander.hagg@h-brs.de
% Dec 2017; Last revision: 12-Dec-2017

%%------------- BEGIN CODE --------------
mirror = mirror - mean(mirror')';
mirror = mirror'*d.FfdP.rotMat;
[maxVertex,maxVertexID] = max(mirror(:,2));
[minVertex,minVertexID] = min(mirror(:,2));
%[~,maxVertexID] = intersect(mirror(:,2)',mirror(maxVertexID,2));
%[~,minVertexID] = intersect(mirror(:,2)',mirror(minVertexID,2));
length = (maxVertex - minVertex);
%% ------------- END OF CODE --------------
% figure(1);%hold off;
% scatter3(mirror(:,1),mirror(:,2),mirror(:,3));view(0,90);
% hold on;
% scatter3(mirror(minVertexID,1),mirror(minVertexID,2),500,32,'k','filled');
% scatter3(mirror(maxVertexID,1),mirror(maxVertexID,2),500,32,'b','filled');
% 
% view(0,90);axis equal;
% axis([-120 120 -200 200 -100 500]);
% axis equal;










