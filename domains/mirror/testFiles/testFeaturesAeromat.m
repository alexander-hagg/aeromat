DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;


%genes = initSamples(1:100,:);
genes = rand(100,d.dof);
[feature] = mirror_Categorize(genes, d);
figure(99); scatter(feature(:,1),feature(:,2));

%%
phenotypes = visPrepPhenotypes('initPhenotypes.mat',genes);

%%
clear fig;
fig(1) = figure(3);hold off;
pointSize = 1
for i=1:size(genes,1)
    vX = phenotypes{i}.vertices(1,:) + feature(i,1)*10;
    vY = phenotypes{i}.vertices(2,:) + feature(i,2)*10;
    vZ = phenotypes{i}.vertices(3,:);
    scatter3(vX,vY,vZ,pointSize,'k','filled');
    hold on;
    %drawnow;
    disp([int2str(i) '/' int2str(size(genes,1))]);
end
view(0,90);
axis equal;