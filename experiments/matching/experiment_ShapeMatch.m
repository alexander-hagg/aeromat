%% Configuration

clear;clc;
% ----------------------------------------------------------------------------------
disp(['>>> Configuration']);
DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;
p.infill            = infillParamSet;

dataDir = 'data/100InitialSamples';
[phenotype, validity, ffdP] = mirror_ffd_Express(0.5*ones(1,d.dof), 'mirrorBase.stl');
d.base = ffdP;

[F,target] = stlread([dataDir '/test_1.stl']);
[~,IDs] = unique(target(:,1)); % Somehow the STL files contain multiple instances of every node..
IDs = sort(IDs);
target = target(IDs,:);

dataFile = 'data/shapematching/mirrorShapeFitGetParameters.mat';
if exist(dataFile,'file')
    load(dataFile);
else    
    for i=1:100
        [F,target] = stlread([dataDir '/test_' int2str(i) '.stl']);
        %target = target(IDs,:);
        
        [params(i,:),coords(i,:),error(i)] = shapeMatch('mirror_ffd_Express',d.dof,target,d);
        disp(error)
    end
end

%%
[maxErr,maxErrid] = max(error)
[F,target] = stlread([dataDir '/test_' int2str(maxErrid) '.stl']);

phenotype = feval('mirror_ffd_Express',params(maxErrid,:),'mirrorBase.stl');

figure(1);
hold off;
scatter3(phenotype.vertices(1,:),phenotype.vertices(2,:),phenotype.vertices(3,:))
view(0,90)
%view(0,180)
title('Approximation');
axis([-80 60 -150 150 600 800]);
hold on;
%figure(2);
scatter3(target(:,1),target(:,2),target(:,3))
title('Target Shape');
view(0,90)
axis([-80 60 -150 150 600 800]);
%view(0,180)
drawnow;

figure(2);histogram(error,50)

%-------------