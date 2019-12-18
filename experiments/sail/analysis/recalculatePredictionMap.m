DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

load('RANS_INCOMPRESSIBLE_4.mat');


%%
p.featureResolution = [50 50];
p.nGens = 8000;
p.display.illu = true;
p.display.illuMod = 25;

initSurrogate = surrogate;

[predMap] = createPredictionMap(initSurrogate,'mirror_AcquisitionFunc',p,d);


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
nonskipped = all((mod(positioning,6)==0)');
nBins = 8;
clrs = parula(nBins+1);clrs(1,:) = [];
clrs = flipud(clrs);
[~,~,binAssignment] = histcounts(exp(fitness),nBins);


divider = 12;
pointSize = 1;

clear fig;
fig(1) = figure;hold off;
for i=1:numel(fitness)
    if ~nonskipped(i); continue; end
    vX = phenotypes{i}.vertices(1,1:2:end);
    vY = phenotypes{i}.vertices(2,1:2:end);
    vZ = phenotypes{i}.vertices(3,1:2:end);
    scatter3(vX + positioning(i,1)/divider, vY + positioning(i,2)/divider, vZ,pointSize,clrs(binAssignment(i),:),'filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end

view(100,20)
axis equal; 
title('Phenotypes in Feature Space RANS');
xlabel(d.featureLabels{1});
ylabel(d.featureLabels{2});
ax = gca;
ax.XTick = [];
ax.YTick = [];
ax.ZTick = [];

cb = colorbar;
cb.Label.String = 'Fitness';



%% Show Prototypes
% Flatten phenotypes
flatPhenos = [];
for i=1:size(phenotypes,2)
    flatPhenos(i,:) = phenotypes{i}.vertices(:);
end

%% Get phenotypic similarity
pcaDims = 40; perplexity = 50; theta = 0.7;
mappedX = fast_tsne(flatPhenos, 2, pcaDims, perplexity, theta)

%%
minMap = min(mappedX(:));
maxMap = max(mappedX(:));
normMappedX = 3*(mappedX-minMap)./(maxMap-minMap);

numPrototypes = 10;
[idx,~,~,~,centroids] = kmedoids(mappedX,numPrototypes)%,'Distance','correlation');

clear fig;
fig(1) = figure(1);hold off;
pointSize = 1
for cI=1:length(centroids)
    i = centroids(cI);
    vX = phenotypes{i}.vertices(1,:);
    vY = phenotypes{i}.vertices(2,:);
    vZ = phenotypes{i}.vertices(3,:);
    scatter3(vX + normMappedX(i,1),vY + normMappedX(i,2),vZ,pointSize,clrs(binAssignment(i),:),'filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end

view(0,90)
axis equal; axis tight;
view(100,20)
title('Morphological Prototypes RANS');
ax = gca;
ax.XTick = [];
ax.YTick = [];
ax.ZTick = [];

cb = colorbar;
cb.Label.String = 'Fitness';

%% Scatter plots of fitness values of families

figure(1);hold off;
for i=1:max(idx)
    isFamily = (idx==i);
    familyFit = exp(fitness(isFamily));
    scatter(repmat([i],sum(isFamily),1),familyFit,16,'k','filled');
    hold on;
    scatter(i,exp(fitness(centroids(i))),32,'r','filled');
    
    scatter(i,median(familyFit),32,'b','filled');
end

xlabel('Families');
ylabel('Fitness Values');

title('Prototype Fitness = red, Median Fitness = blue');
