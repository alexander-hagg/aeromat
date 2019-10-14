clear;clc;
load('RANS.mat');   mapRANS1 = map;
load('RANS2.mat');  mapRANS2 = map;
load('LES.mat');    mapLES1 = map;
load('LES2.mat');   mapLES2 = map;

%%

genesRANS1 = reshape(mapRANS1.genes,[],size(mapRANS1.genes,3));
genesRANS1 = genesRANS1(all(~isnan(genesRANS1)'),:);
setMarkers = size(genesRANS1,1);

genesRANS2 = reshape(mapRANS2.genes,[],size(mapRANS2.genes,3));
genesRANS2 = genesRANS2(all(~isnan(genesRANS2)'),:);
setMarkers(2) = setMarkers(1) + size(genesRANS2,1);

genesLES1 = reshape(mapLES1.genes,[],size(mapLES1.genes,3));
genesLES1 = genesLES1(all(~isnan(genesLES1)'),:);
setMarkers(3) = setMarkers(2) + size(genesLES1,1);

genesLES2 = reshape(mapLES2.genes,[],size(mapLES2.genes,3));
genesLES2 = genesLES2(all(~isnan(genesLES2)'),:);
setMarkers(4) = setMarkers(3) + size(genesLES2,1);

no_dims = 2;
initial_dims = size(genesRANS1,2);
perplexity = 50;
theta = 0.2; % Quality-speed trade off. Higher is faster, lower quality

mappedX = fast_tsne([genesRANS1;genesRANS2;genesLES1;genesLES2], no_dims, initial_dims, perplexity, theta);

%% TSNE plot
figure(4); hold off;
cmap = hsv(4);
scatter(mappedX(1:setMarkers(1),1),mappedX(1:setMarkers(1),2),32,cmap(1,:),'filled');
hold on;
scatter(mappedX(setMarkers(1)+1:setMarkers(2),1),mappedX(setMarkers(1)+1:setMarkers(2),2),32,cmap(2,:),'filled');
scatter(mappedX(setMarkers(2)+1:setMarkers(3),1),mappedX(setMarkers(2)+1:setMarkers(3),2),32,cmap(3,:),'filled');
scatter(mappedX(setMarkers(3)+1:setMarkers(4),1),mappedX(setMarkers(3)+1:setMarkers(4),2),32,cmap(4,:),'filled');


legend('RANS run 1','RANS run 2','LES run 1','LES run 2');
title('Genomes found (projected with t-SNE)');

%% Parameter plot
figure(5);hold off;
step = 1; alpha = 0.05;
plot(genesRANS1(1:step:end,:)','Color',[cmap(1,:) alpha]);

hold on;
plot(genesLES1(1:step:end,:)','Color',[cmap(2,:) alpha]);

axis([1 36 0 1]);
l = legend('RANS','LES');
title('Parameters found with QD: RANS (red) vs LES (green)');
xlabel('Parameter ID');
ylabel('Parameter Value');
%% END CODE
