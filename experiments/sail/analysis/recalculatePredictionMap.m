DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

load('RANS_INCOMPRESSIBLE_3.mat');


%%
p.featureResolution = [50 50];
p.nGens = 1000;
p.display.illu = true;
p.display.illuMod = 25;

initSurrogate = surrogate;

%initSurrogate.trainInput = initSurrogate.trainInput(1:100,:);
%initSurrogate.trainOutput = initSurrogate.trainInput(1:100);

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
nonskipped = all((mod(positioning,4)==0)');
divider = 8;
pointSize = 4;

clear fig;
fig(1) = figure;hold off;
for i=1:numel(fitness)
    if ~nonskipped(i); continue; end
    vX = phenotypes{i}.vertices(1,1:2:end);
    vY = phenotypes{i}.vertices(2,1:2:end);
    vZ = phenotypes{i}.vertices(3,1:2:end);
    scatter3(vX + positioning(i,1)/divider, vY + positioning(i,2)/divider, vZ,pointSize,'k','filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end

view(0,90)
%axis([min(normMappedX(:,1)) max(normMappedX(:,1))+0.2 min(normMappedX(:,2)) max(normMappedX(:,2))+0.2 -1 2]);
axis equal; 
%axis tight;
title('Phenotypes in Feature Space RANS');

%% Show Prototypes
% Flatten phenotypes
flatPhenos = [];
for i=1:size(genes,1)
    flatPhenos(i,:) = phenotypes{i}.vertices(:);
end

%% Get phenotypic similarity
pcaDims = 40; perplexity = 50; theta = 0.6;
mappedX = fast_tsne(flatPhenos, 2, pcaDims, perplexity, theta)

%%
minMap = min(mappedX(:));
maxMap = max(mappedX(:));
normMappedX = 3*(mappedX-minMap)./(maxMap-minMap);

numPrototypes = 30;
[~,~,~,~,centroids] = kmedoids(mappedX,numPrototypes)%,'Distance','correlation');

clear fig;
fig(1) = figure(1);hold off;
pointSize = 1
for cI=1:length(centroids)
    i = centroids(cI);
    vX = phenotypes{i}.vertices(1,:) + normMappedX(i,1);
    vY = phenotypes{i}.vertices(2,:) + normMappedX(i,2);
    vZ = phenotypes{i}.vertices(3,:);
    scatter3(vX,vY,vZ,pointSize,'k','filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end

view(0,90)
%axis([min(normMappedX(:,1)) max(normMappedX(:,1))+0.2 min(normMappedX(:,2)) max(normMappedX(:,2))+0.2 -1 2]);
axis equal; axis tight;
title('Morphological Prototypes RANS');


