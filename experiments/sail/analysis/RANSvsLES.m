DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

resultsRANS = load('RANS_INCOMPRESSIBLE_4.mat');
resultsLES  = load('LES_COMPRESSIBLE_6.mat');

%%
p.featureResolution = [25 25];
p.nGens = 4000;
p.display.illu = false;p.display.illuMod = 25;

[resultsRANS.map] = createPredictionMap(resultsRANS.surrogate,'mirror_AcquisitionFunc',p,d);
[resultsLES.map] = createPredictionMap(resultsLES.surrogate,'mirror_AcquisitionFunc',p,d);


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

cmap = parula(3);cmap(1,:) = [];
clrs = [repmat(cmap(1,:),numel(phenotypesRANS),1);repmat(cmap(2,:),numel(phenotypesLES),1)];

%% Calculate Similarity

perplexity = 50; theta = 0.3;
% Genetic similarity
mappedGenes = tsne(genes,'Algorithm','barneshut','Perplexity',perplexity,'Theta',theta);
% Phenotypic similarity
mappedX = tsne(flatPhenos','Algorithm','barneshut','Perplexity',perplexity,'Theta',theta);

%%
figure(1);
scatter(mappedGenes(:,1),mappedGenes(:,2),32,clrs,'filled');
title('Genetic similarity');

figure(2);
scatter(mappedX(:,1),mappedX(:,2),32,clrs,'filled');
title('Phenotypic similarity');


%%

skip = 7;
%fitness = feval('predictGP', resultsRANS.surrogate, genes);
%fitness = fitness(:,1);

nonskipped = all((mod(positioning,skip)==0)');
nBins = 16;
clrs = parula(nBins+1);clrs(1,:) = [];



%edges = [0,0.3:(0.1/5):0.4,1]
edges = [0,0.5:(0.2/5):0.7,1]
[~,edges,binAssignment] = histcounts(fitness,edges);

binAssignment = binAssignment + 1;


pointSize = 2;

clear fig;
fig(1) = figure;hold off;
for i=1:numel(fitness)
    if ~nonskipped(i); continue; end
    vX = phenotypes{i}.vertices(1,1:2:end);
    vY = phenotypes{i}.vertices(2,1:2:end);
    vZ = phenotypes{i}.vertices(3,1:2:end);
    zPosition = 0;
    if i > length(fitnessRANS)
        zPosition = 0.5;
    end
    scatter3(vX + positioning(i,1)/skip/2, vY + positioning(i,2)/skip/2, vZ+zPosition,pointSize,clrs(binAssignment(i),:),'filled');
    hold on;
    drawnow;
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
%caxis([0.3 0.42]);
cb.Label.String = 'cD';
%cb.TickLabels{1} = '< 0.3';
%cb.TickLabels{end} = '> 0.42';
