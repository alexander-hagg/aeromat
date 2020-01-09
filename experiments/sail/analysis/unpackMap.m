function [genes,fitness,phenotypes,positioning] = unpackMap(predMap,d)
%UNPACKMAP Summary of this function goes here
%   Detailed explanation goes here
genes = reshape(predMap.genes,[],d.dof);
fitness = reshape(predMap.fitness,[],1);

xPosMap = 1:size(predMap.fitness,1);
yPosMap = 1:size(predMap.fitness,2);
[X,Y] = ndgrid(xPosMap,yPosMap);
positioning = [X(:) Y(:)];

genes(all(isnan(genes)'),:) = [];
positioning(isnan(fitness),:) = [];
fitness(isnan(fitness)) = [];

phenotypes = getPrepPhenotypes(genes,[]);
end

