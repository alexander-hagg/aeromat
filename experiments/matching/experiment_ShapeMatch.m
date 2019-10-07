%% Configuration

clear;clc;
% ----------------------------------------------------------------------------------
disp(['>>> Configuration']);
DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;
p.infill            = infillParamSet;
surrogateAssistance = true;

% uncomment this for real evaluation
d.preciseEvaluate = 'mirror_DummyPreciseEvaluate';

dataDir = 'data/100InitialSamples';
[phenotype, validity, ffdP] = mirror_ffd_Express(0.5*ones(1,d.dof), 'mirrorBase.stl');
d.base = ffdP;

%%

[F,target] = stlread([dataDir '/test_1.stl']);
[~,IDs] = unique(target(:,1)); % Somehow the STL files contain multiple instances of every node..
IDs = sort(IDs);
target = target(IDs,:);

%%
%figure(1);
%scatter3(phenotype.vertices(1,1:50:end),phenotype.vertices(2,1:50:end),phenotype.vertices(3,1:50:end))
%view(0,180)
%%
for i=1:100
    [F,target] = stlread([dataDir '/test_' int2str(i) '.stl']);
    %target = target(IDs,:);
    
    [params(i,:),coords(i,:),error(i)] = shapeMatch('mirror_ffd_Express',d.dof,target,d);
    disp(error)
end

