DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;

load('RANS_INCOMPRESSIBLE_3.mat');

map.fitness = -map.fitness;
genes = reshape(map.genes,[],d.dof);
fitness = reshape(map.fitness,[],1);

xPosMap = 1:size(map.fitness,1);
yPosMap = 1:size(map.fitness,2);
[X,Y] = ndgrid(xPosMap,yPosMap);
positioning = [X(:) Y(:)];

genes(all(isnan(genes)'),:) = [];
positioning(isnan(fitness),:) = [];
fitness(isnan(fitness)) = [];
%%
%[feature] = mirror_Categorize(genes, d)

figure(1);hold off
scatter3(phenotypes{1}.vertices(1,:),phenotypes{1}.vertices(2,:),phenotypes{1}.vertices(3,:),4,'r','filled');
hold on;
scatter3(phenotypes{900}.vertices(1,:),phenotypes{900}.vertices(2,:),phenotypes{900}.vertices(3,:),4,'g','filled');
scatter3(phenotypes{end}.vertices(1,:),phenotypes{end}.vertices(2,:),phenotypes{end}.vertices(3,:),4,'b','filled');
view(0,90);axis equal;
mirror_Categorize(genes([1 900 1889],:), d)

%% Get phenotypes either from disk or generate them
phenotypes = visPrepPhenotypes('phenotypesRANS.mat',genes);


%%
nonskipped = all((mod(positioning,10)==0)');

clear fig;
fig(1) = figure(3);hold off;
pointSize = 1
for i=1:numel(fitness)
    if ~nonskipped(i); continue; end
    vX = phenotypes{i}.vertices(1,:) + positioning(i,1)/10;
    vY = phenotypes{i}.vertices(2,:) + positioning(i,2)/10;
    vZ = phenotypes{i}.vertices(3,:);
    scatter3(vX,vY,vZ,pointSize,'k','filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end

view(0,90)
%axis([min(normMappedX(:,1)) max(normMappedX(:,1))+0.2 min(normMappedX(:,2)) max(normMappedX(:,2))+0.2 -1 2]);
axis equal; axis tight;
title('Phenotypes in Feature Space RANS');


experimentDirName = 'experiments_results';
mkdir(experimentDirName);

save_figures(fig, experimentDirName, 'phenotypesInFeatureSpace', 10, [20 20])



