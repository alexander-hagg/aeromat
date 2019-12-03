function phenotypes = visPrepPhenotypes(phenotypeData,genes)
if exist(phenotypeData,'file')
    phenotypes = load(phenotypeData);
    phenotypes = phenotypes.phenotypes;
else
    for i=1:size(genes,1)
        [FV{i}, ~, ffdP] = mirror_ffd_Express(genes(i,:), 'mirrorBase.stl');
        disp([int2str(i) '/' int2str(size(genes,1))])
    end
    
    phenotypes = FV;
    minV = min(FV{i}.vertices(:));
    maxV = max(FV{i}.vertices(:));
    
    for i=1:size(genes,1)
        phenotypes{i}.vertices = (phenotypes{i}.vertices-minV)./(maxV-minV);
    end
    
    save(phenotypeData,'phenotypes');
end
end