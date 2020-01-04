DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

resultsRANS = load('RANS_INCOMPRESSIBLE_4.mat');
resultsLES  = load('LES_COMPRESSIBLE_6.mat');

%%
p.featureResolution = [25 25];
p.nGens = 100;
p.display.illu = false;p.display.illuMod = 25;

[resultsRANS.map] = createPredictionMap(resultsRANS.surrogate,'mirror_AcquisitionFunc',p,d);
[resultsLES.map] = createPredictionMap(resultsLES.surrogate,'mirror_AcquisitionFunc',p,d);


%%
[genesRANS,fitnessRANS,phenotypesRANS,positioningRANS] = unpackMap(resultsRANS.map,d);
[genesLES,fitnessLES,phenotypesLES,positioningLES] = unpackMap(resultsLES.map,d);

genes = [genesRANS;genesLES];
phenotypes = [phenotypesRANS,phenotypesLES];
fitness = [fitnessRANS;fitnessLES];

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
