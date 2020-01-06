DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

resultsRANS = load('RANS_INCOMPRESSIBLE_4.mat');
resultsLES  = load('LES_COMPRESSIBLE_5.mat');


%%
p.featureResolution = [25 25];
p.nGens = 4000;
p.display.illu = false;
p.display.illuMod = 25;

initSurrogate = surrogate;

[predMap] = createPredictionMap(initSurrogate,'mirror_AcquisitionFunc',p,d);

predMap.fitness = exp(-predMap.fitness);
[~,~,cHandle] = viewMap(predMap,d);cHandle.Label.String = 'cD';


%%
[genes,fitness,phenotypes,positioning] = unpackMap(predMap,d);

% Flatten phenotypes
flatPhenos = [];
for i=1:size(phenotypes,2)
    flatPhenos(i,:) = phenotypes{i}.vertices(:);
end

%%
skip = 16;

nonskipped = all((mod(positioning,skip)==0)');
nBins = 8;
clrs = parula(nBins+1);clrs(1,:) = [];

%edges = [0,0.3:(0.1/5):0.4,1]
edges = [0,0.5:(0.2/5):0.7,1]
[~,edges,binAssignment] = histcounts(fitness,edges);


pointSize = 1;

clear fig;
fig(1) = figure;hold off;
for i=1:numel(fitness)
    if ~nonskipped(i); continue; end
    vX = phenotypes{i}.vertices(1,1:2:end);
    vY = phenotypes{i}.vertices(2,1:2:end);
    vZ = phenotypes{i}.vertices(3,1:2:end);
    scatter3(vX + positioning(i,1)/skip/2, vY + positioning(i,2)/skip/2, vZ,pointSize,clrs(binAssignment(i),:),'filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
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
caxis([0.3 0.42]);
cb.Label.String = 'cD';
cb.TickLabels{1} = '< 0.3';
cb.TickLabels{end} = '> 0.42';



%% Show Prototypes
% Get phenotypic similarity
perplexity = 50; theta = 0.7;
%mappedX = fast_tsne(flatPhenos, 2, pcaDims, perplexity, theta)
mappedX = tsne(flatPhenos,'Algorithm','barneshut','Perplexity',perplexity,'Theta',theta);


%%
minMap = min(mappedX(:));
maxMap = max(mappedX(:));
normMappedX = 3*(mappedX-minMap)./(maxMap-minMap);

prototypeLayers = [5 10 20 40];
%prototypeLayers = [5];

clear fig;
fig(1) = figure(1);hold off;
pointSize = 1;
for ii=1:length(prototypeLayers)
    numPrototypes = prototypeLayers(ii);
    [idx,~,~,~,centroids] = kmedoids(mappedX,numPrototypes);
    
    subplot(length(prototypeLayers),1,ii);hold off;
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
    title(['Morphological Prototypes RANS, k = ' int2str(prototypeLayers(ii))]);
    
axis equal; axis tight;
view(100,20)
ax = gca;
ax.XTick = [];
ax.YTick = [];
ax.ZTick = [];
end


cb = colorbar;
caxis([0.3 0.42]);
cb.Label.String = 'cD';
cb.TickLabels{1} = '< 0.3';
cb.TickLabels{end} = '> 0.42';



%% Scatter plots of fitness values of families

figure(1);hold off;
for i=1:max(idx)
    isFamily = (idx==i);
    familyFit = fitness(isFamily);
    scatter(repmat([i],sum(isFamily),1),familyFit,16,'k','filled');
    hold on;
    scatter(i,fitness(centroids(i)),32,'r','filled');
    
    scatter(i,median(familyFit),32,'b','filled');
end

xlabel('Families');
ylabel('Fitness Values');

title('Prototype Fitness = red, Median Fitness = blue');
