DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;

load('RANS_INCOMPRESSIBLE_3.mat');

map.fitness = -map.fitness;
genes = reshape(map.genes,[],d.dof);
fitness = reshape(map.fitness,[],1);
genes(all(isnan(genes)'),:) = [];
fitness(isnan(fitness)) = [];


%% Get phenotypes either from disk or generate them
phenotypes = visPrepPhenotypes('phenotypesRANS.mat',genes);

%% Flatten phenotypes
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
title('Prototypes RANS');


experimentDirName = 'experiments_results';
mkdir(experimentDirName);

save_figures(fig, experimentDirName, 'prototypes', 10, [20 20])



