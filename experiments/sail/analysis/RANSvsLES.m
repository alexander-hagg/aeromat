DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

resultsRANS = load('RANS_INCOMPRESSIBLE_4.mat');
resultsLES  = load('LES_COMPRESSIBLE_9.mat');

%%
load('data/initSetParamsAndFitness.mat');
initSamples = mirrorParams;

p.featureResolution = [50 50];
p.nGens = 4000;
p.display.illu = false;p.display.illuMod = 25;

[resultsRANS.map, allMapsRANS] = createPredictionMap(resultsRANS.surrogate,'mirror_AcquisitionFunc',p,d,initSamples);
[resultsLES.map, allMapsLES] = createPredictionMap(resultsLES.surrogate,'mirror_AcquisitionFunc',p,d,initSamples);

%%
[genesRANS,fitnessRANS,phenotypesRANS,positioningRANS] = unpackMap(resultsRANS.map,d);
[genesLES,fitnessLES,phenotypesLES,positioningLES] = unpackMap(resultsLES.map,d);

genes = [genesRANS;genesLES];
phenotypes = [phenotypesRANS,phenotypesLES];
fitness = [fitnessRANS;fitnessLES];
positioning = [positioningRANS;positioningLES];

flatPhenos = [];
for i=1:size(phenotypes,2)
    flatPhenos(:,i) = phenotypes{i}.vertices(:);
end

%% Calculate Similarity

perplexity = 50; theta = 0.1;
% Genetic similarity                    %, 'Distance', 'cityblock');%,'Distance','correlation','Verbose',2);
mappedGenes = tsne(genes,'Algorithm','barneshut','Perplexity',perplexity,'Theta',theta);
% Phenotypic similarity
mappedPhenos = tsne(flatPhenos','Algorithm','barneshut','Perplexity',perplexity,'Theta',theta);
save('aeromat','d','p','resultsRANS','resultsLES','initSamples','mappedGenes','mappedPhenos');

%% Show similarity spaces (genetic and phenotypic)
figure(1);
hold off;
psize = 8;
cmap = parula(3);cmap(1,:) = [];
h1 = scatter(mappedGenes(1:numel(phenotypesRANS),1),mappedGenes(1:numel(phenotypesRANS),2),psize,repmat(cmap(1,:),numel(phenotypesRANS),1),'filled');
hold on;
h2 = scatter(mappedGenes(numel(phenotypesRANS)+1:end,1),mappedGenes(numel(phenotypesRANS)+1:end,2),psize,repmat(cmap(2,:),numel(phenotypesLES),1),'filled');
title('Genetic similarity');
legend([h1 h2],'RANS','LES');

figure(2);
h1 = scatter(mappedPhenos(1:numel(phenotypesRANS),1),mappedPhenos(1:numel(phenotypesRANS),2),psize,repmat(cmap(1,:),numel(phenotypesRANS),1),'filled');
hold on;
h2 = scatter(mappedPhenos(numel(phenotypesRANS)+1:end,1),mappedPhenos(numel(phenotypesRANS)+1:end,2),psize,repmat(cmap(2,:),numel(phenotypesLES),1),'filled');

title('Phenotypic similarity');
legend([h1 h2],'RANS','LES');



%% ANALYSIS


cmap = parula(3);cmap(1,:) = [];
colorsCFD = [repmat(cmap(1,:),numel(phenotypesRANS),1);repmat(cmap(2,:),numel(phenotypesLES),1)];

% 19 26 27 28
for i=3%1:numPrototypes
    figure;
    h = visPhenotypes(phenotypes(idxG==i),positioning(idxG==i,:)/4,colorsCFD(idxG==i,:));
    axis equal;
    view(0,90);
    title('Genetic Similarity, mixed class');
    ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
    [un,~,ids] = unique(colorsCFD(idxG==i,:),'rows');    
    h1 = scatter(nan,nan,32,cmap(1,:),'filled');
    h2 = scatter(nan,nan,32,cmap(2,:),'filled');
    legend([h1 h2],'RANS','LES');
    drawnow;
end


%% Show cluster-wise phenotypes
cmap = parula(3);cmap(1,:) = [];
colorsCFD = [repmat(cmap(1,:),numel(phenotypesRANS),1);repmat(cmap(2,:),numel(phenotypesLES),1)];

% 2 10
for i=2
    figure;
    h = visPhenotypes(phenotypes(idxP==i),positioning(idxP==i,:)/4,colorsCFD(idxP==i,:));
    view(0,90);
    hold on;
    axis equal;
    title('Phenotypic Similarity, mixed class');
    ax = gca;
    ax.XTick = [];ax.YTick = [];ax.ZTick = [];
    [un,~,ids] = unique(colorsCFD(idxP==i,:),'rows');    
    h1 = scatter(nan,nan,32,un(1,:),'filled');h2 = scatter(nan,nan,32,un(2,:),'filled');
    legend([h1 h2],'RANS','LES');
    drawnow;
end

%% 1. Does phenotypic clustering give us a better natural clustering? Are shapes more similar?
% 	- genetic & phenotypic clustering
% 	- pick LES+RANS cluster from phenotypic clustering
% 	- Show the members of this cluster in genetic and phenotypic similarity space
% 	- metric?
%
%

numPrototypes = 10;
[idxG,~,~,~,centroidsG] = kmedoids(mappedGenes,numPrototypes);
[idxP,~,~,~,centroidsP] = kmedoids(mappedPhenos,numPrototypes);

% Save prototypes to disk

prototypes.phenotypes = {phenotypes{centroidsP}};
prototypes.genomes = genes(centroidsP,:);

save('aeromat','d','p','resultsRANS','resultsLES','initSamples','mappedGenes','mappedPhenos','prototypes');

%%

cmap = hsv(numPrototypes+1);cmap(1,:)=[];
sz = 32;
figure(1);hold off;
scatter(mappedGenes(1:numel(phenotypesRANS),1),mappedGenes(1:numel(phenotypesRANS),2),sz,cmap(idxG(1:numel(phenotypesRANS)),:),'filled','MarkerEdgeColor','k');hold on;
scatter(mappedGenes(numel(phenotypesRANS)+1:end,1),mappedGenes(numel(phenotypesRANS)+1:end,2),sz,cmap(idxG(numel(phenotypesRANS)+1:end),:),'d','filled','MarkerEdgeColor','k');
ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
title('Genetic Clusters');


figure(2);hold off;
scatter(mappedPhenos(1:numel(phenotypesRANS),1),mappedPhenos(1:numel(phenotypesRANS),2),sz,cmap(idxP(1:numel(phenotypesRANS)),:),'filled','MarkerEdgeColor','k');hold on;
scatter(mappedPhenos(numel(phenotypesRANS)+1:end,1),mappedPhenos(numel(phenotypesRANS)+1:end,2),sz,cmap(idxP(numel(phenotypesRANS)+1:end),:),'d','filled','MarkerEdgeColor','k');
ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
title('Phenotypic Clusters');

%% 2. Representation by Prototypes
cmap = parula(3);cmap(1,:) = [];
colorsCFD = [repmat(cmap(1,:),numel(phenotypesRANS),1);repmat(cmap(2,:),numel(phenotypesLES),1)];

clusterIDs = idxP; %idxG idxP
centroids = centroidsP; %centroidsG centroidsP

clear fig;
for i=1:numPrototypes
    fig(i) = figure(i);
    subplot(3,3,1);hold off;
    scatter(mappedPhenos(clusterIDs==i,1),mappedPhenos(clusterIDs==i,2),16,colorsCFD(clusterIDs==i,:),'filled');
    hold on;
    scatter(mappedPhenos(centroids(i),1),mappedPhenos(centroids(i),2),32,'r','filled');
    axis equal;ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
    [un,~,ids] = unique(colorsCFD,'rows');    
    h1 = scatter(nan,nan,32,un(1,:),'filled');h2 = scatter(nan,nan,32,un(2,:),'filled'); h3 = scatter(nan,nan,32,[1 0 0],'filled');
    l = legend([h1 h2 h3],'RANS','LES','Prototype');
    l.Position(1) = 0.4;
    title('Phenotype Class');
    
    
    subplot(3,3,3);hold off;
    skip = 0.1;
    minGrid = min(mappedPhenos(clusterIDs==i,:));maxGrid = max(mappedPhenos(clusterIDs==i,:));
    [xq,yq] = meshgrid(minGrid(1):skip:maxGrid(1), minGrid(2):skip:maxGrid(2));
    vq = griddata(mappedPhenos(clusterIDs==i,1),mappedPhenos(clusterIDs==i,2),fitness(clusterIDs==i),xq,yq,'natural');
    sf = surf(xq,yq,vq);
    sf.EdgeAlpha = 0;
    view(0,90);
    axis equal;ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
    title('Fitness');
    
    subplot(3,3,[4,5,7,8]);hold off;
    h = visPhenotypes(phenotypes(centroids(i)),[0 0],'k',2);
    axis equal;ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
    view(120,20);
    axis([-0.05 0.2 -0.1 0.3 0.8 1.05]);
    title('Prototype');
    
    subplot(3,3,6);hold off;
    h = visPhenotypes(phenotypes(centroids(i)),[0 0],'k',2);
    axis equal;ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
    view(0,90);
    axis([-0.05 0.2 -0.1 0.3 0.8 1.05]);
    
    subplot(3,3,9);hold off;
    h = visPhenotypes(phenotypes(centroids(i)),[0 0],'k',2);
    axis equal;ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];
    view(0,0);
    axis([-0.05 0.2 -0.1 0.3 0.8 1.05]);
    
    drawnow;
end

save_figures(fig, '.', 'classes', 16, [7 9])






%% Hierarchical clustering

T = clusterdata(flatPhenos,'Linkage','ward','SaveMemory','on','Maxclust',32);
tree = linkage(flatPhenos,'ward');
dendrogram(tree)

%% 3. Differences between LES and RANS
figure(2);
h2 = scatter(mappedPhenos(:,1),mappedPhenos(:,2),8,cmap(idxP),'filled');


% 	- Plot 1 cluster per figure, including
% 		- RANS/LES per cluster (boundary color)
% 		- cluster ID (color)
%
% 	- Pick prototypes of three clusters
% 		- a. LES only
% 		- b. RANS only
% 		- c. LES plus RANS
%
%   - run CFD (LES & RANS) on three prototypes to analyze flow
%   - what are the differences? Why does a RANS prototype not perform well
%   in LES?
%
% - Plot prototype + convex hull of clusters
%









%%

skip = 5;
%fitness = feval('predictGP', resultsRANS.surrogate, genes);
%fitness = fitness(:,1);

nonskipped = all((mod(positioning,skip)==0)');
nBins = 16;
clrs = parula(nBins+1);clrs(1,:) = [];

edges = [0,0.5:(0.2/5):0.7,1]
[~,edges,binAssignment] = histcounts(fitness,edges);

binAssignment = binAssignment + 1;
pointSize = 2;

clear fig;
fig(1) = figure;hold off;
for i=1:numel(phenotypes)
    if ~nonskipped(i); continue; end
    vX = phenotypes{i}.vertices(1,1:2:end);
    vY = phenotypes{i}.vertices(2,1:2:end);
    vZ = phenotypes{i}.vertices(3,1:2:end);
    scatter3(vX + positioning(i,1)/skip/2, vY + positioning(i,2)/skip/2, vZ+zPosition,pointSize,clrs(binAssignment(i),:),'filled');
    hold on;
    drawnow;
end

view(100,20)
axis equal;
title(['Selection of Phenotypes from ' int2str(p.featureResolution(1)) 'x' int2str(p.featureResolution(2)) ' Feature Space RANS']);
xlabel(d.featureLabels{1});
ylabel(d.featureLabels{2});
ax = gca;
ax.XTick = [];
ax.YTick = [];
ax.ZTick = [];

cb = colorbar;
%caxis([0.3 0.42]);
cb.Label.String = 'cD';
%cb.TickLabels{1} = '< 0.3';
%cb.TickLabels{end} = '> 0.42';


%%

clrs = [repmat(cmap(1,:),numel(phenotypesRANS),1);repmat(cmap(2,:),numel(phenotypesLES),1)];

minMap = min(mappedPhenos(:));
maxMap = max(mappedPhenos(:));
normmappedPhenos = 3*(mappedPhenos-minMap)./(maxMap-minMap);

clear fig;
fig(1) = figure(1);hold off;
pointSize = 1;
numPrototypes = 5
[idx,~,~,~,centroids] = kmedoids(mappedPhenos,numPrototypes);

subplot(length(prototypeLayers),1,ii);hold off;
for cI=1:length(centroids)
    i = centroids(cI);
    vX = phenotypes{i}.vertices(1,:);
    vY = phenotypes{i}.vertices(2,:);
    vZ = phenotypes{i}.vertices(3,:);
    scatter3(vX + normmappedPhenos(i,1),vY + normmappedPhenos(i,2),vZ,pointSize*2,clrs(binAssignment(i),:),'filled');
    %scatter3(vX + normmappedPhenos(i,1),vY + normmappedPhenos(i,2),vZ,pointSize,clrs(i,:),'filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end
title(['Morphological Prototypes RANS, k = ' int2str(prototypeLayers(ii))]);

axis equal; axis tight;view(100,20);ax = gca;ax.XTick = [];ax.YTick = [];ax.ZTick = [];


cb = colorbar;caxis([0.3 0.42]);cb.Label.String = 'cD';cb.TickLabels{1} = '< 0.3';cb.TickLabels{end} = '> 0.42';


