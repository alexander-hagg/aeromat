DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

load('RANS_INCOMPRESSIBLE_3.mat');


%%
p.featureResolution = [50 50];
p.nGens = 200;

initSurrogate = surrogate;

initSurrogate.trainInput = initSurrogate.trainInput(1:100,:);
initSurrogate.trainOutput = initSurrogate.trainInput(1:100);

[predMap] = createPredictionMap(initSurrogate,'mirror_AcquisitionFunc',p,d);

%%

viewMap(predMap,d)

%%
predMap.fitness = -predMap.fitness;
genes = reshape(predMap.genes,[],d.dof);
fitness = reshape(predMap.fitness,[],1);

xPosMap = 1:size(predMap.fitness,1);
yPosMap = 1:size(predMap.fitness,2);
[X,Y] = ndgrid(xPosMap,yPosMap);
positioning = [X(:) Y(:)];

genes(all(isnan(genes)'),:) = [];
positioning(isnan(fitness),:) = [];
fitness(isnan(fitness)) = [];

phenotypes = visPrepPhenotypes('initPhenotypes.mat',genes);


%%
nonskipped = all((mod(positioning,2)==0)');

clear fig;
fig(1) = figure;hold off;
pointSize = 1;
for i=1:numel(fitness)
    if ~nonskipped(i); continue; end
    vX = phenotypes{i}.vertices(1,:);
    vY = phenotypes{i}.vertices(2,:);
    vZ = phenotypes{i}.vertices(3,:);
    scatter3(vY + positioning(i,1)/5, vZ + positioning(i,2)/5, vX,pointSize,'k','filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end

view(0,90)
%axis([min(normMappedX(:,1)) max(normMappedX(:,1))+0.2 min(normMappedX(:,2)) max(normMappedX(:,2))+0.2 -1 2]);
axis equal; 
%axis tight;
title('Phenotypes in Feature Space RANS');
