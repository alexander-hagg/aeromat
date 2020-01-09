function phenotypes = getPrepPhenotypes(genes,phenotypeData)
if ~isempty(phenotypeData) && exist(phenotypeData,'file')
    phenotypes = load(phenotypeData);
    phenotypes = phenotypes.phenotypes;
else
    parfor i=1:size(genes,1)
        [FV{i}, ~, ffdP] = mirror_ffd_Express(genes(i,:), 'mirrorBase.stl');
        disp([int2str(i) '/' int2str(size(genes,1))])
    end
    
    phenotypes = FV;
    minV = min(FV{1}.vertices(:));
    maxV = max(FV{1}.vertices(:));
    
    for i=1:size(genes,1)
        phenotypes{i}.vertices = (phenotypes{i}.vertices-minV)./(maxV-minV);
    end
    
    if ~isempty(phenotypeData)
        save(phenotypeData,'phenotypes');
    end
end
end