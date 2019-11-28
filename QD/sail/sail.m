function [predMap,modelPred] = sail(acqMap,p,d,varargin)
%SAIL - Surrogate Assisted Illumination Algorithm
% Main run script of SAIL algorithm
%
% Author: Adam Gaier, Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: adam.gaier@h-brs.de, alexander.hagg@h-brs.de
% Nov 2016; Last revision: 14-Oct-2019

if p.display.illu
    if nargin > 6; figHandleAcqMap = varargin{4};else;f=figure(4);clf(f);figHandleAcqMap = axes; end
    title(figHandleAcqMap,'Acquisition Fcn'); drawnow;
end

p.predMapResolution = p.featureResolution;
p.featureResolution = p.infill.featureResolution;

% Use given samples or extract from map
observation = []; if nargin > 3; observation = varargin{1}; end
trueFitness = []; if nargin > 4; trueFitness = varargin{2}; end
filename = 'saved.mat'; if nargin > 5; filename = varargin{3}; end

if isempty(observation)
    observation = reshape(acqMap.genes,[],d.dof);
    valid = all(~isnan(observation)');
    observation = observation(valid,:);
    nSamples = size(observation,1);
    p.numInitSamples = nSamples; 
    trueFitness = reshape(acqMap.fitness,numel(valid),[]);
    trueFitness = trueFitness(valid,:);
else
    nSamples = size(observation,1);
    p.numInitSamples = nSamples; 
end

parents = observation;
p.infill.modelParams = paramsGP(size(observation,2));
while nSamples <= p.infill.nTotalSamples
    %% 1 - Create Surrogate and Acquisition Function 
    % Surrogate models are created from all evaluated samples, and these
    % models are used to produce an acquisition function.
    p.infill.model.functionEvals = 100;
    model = trainGP(observation,trueFitness,p.infill.modelParams);
    acqFunction = createAcquisitionFcn('mirror_AcquisitionFunc',model,d.varCoef);
    
    % After final model is created no more infill is necessary
    if nSamples >= p.infill.nTotalSamples; break; end
    
    %% 2 - Illuminate Acquisition Map
    % A map is constructed using the evaluated samples which are evaluated
    % with the acquisition function and placed in the map as the initial
    % population. The observed samples are the seed population of the
    % 'acquisition map' which is then created by optimizing the acquisition
    % function with MAP-Elites.
    
    % Evaluate data set with acquisition function
    try
        [fitness,predValue] = acqFunction(parents);
    catch exception
        disp(exception.identifier);
    end
    
    % Place Best Samples in Map with Acquisition Fitness
    acqMap                                              = createMap(d, p);
    [replaced, replacement, percImprovement, features]  = nicheCompete(parents, fitness, acqMap, d, p);
    acqMap                                              = updateMap(replaced,replacement,acqMap,fitness,parents, features);                    

    % Illuminate with QD (but no visualization)
    acqCfg = p;acqCfg.display.illu = false;
    acqMap = illuminate(acqMap,acqFunction,acqCfg,d);
    
    %% 3 - Select Infill Samples
    % The next samples to be tested are chosen from the acquisition map: a
    % sobol sequence is used to to evenly sample the map in the feature
    % dimensions. When evaluated solutions don't converge the next bin in
    % the sobol set is chosen.
    disp(['PE: ' int2str(nSamples) '| Evaluating New Samples']);
    % At first iteration initialize sobol sequence for sample selection
    if nSamples == p.numInitSamples
        if isfield(d,'commonSobolGen')
            sobSet = d.commonSobolGen;
        else
            sobSet  = scramble(sobolset(numel(p.infill.featureResolution),'Skip',1e3),'MatousekAffineOwen');
        end
        if isfield(d,'commonSobolGenPtr')
            sobPoint = commonSobolGenPtr;
        else
            sobPoint= 1;
        end
    end
    
    newValue = nan(p.infill.nAdditionalSamples, size(fitness,2)); % new values will be stored here
    noValue = any(isnan(newValue),2);
    
    while any(any(noValue))
        nNans = sum(noValue);
        nextGenes = nan(nNans,d.dof); % Create one 'blank' genome for each NAN
        
        % Identify (grab indx of NANs)
        nanIndx = 1:p.infill.nAdditionalSamples;  nanIndx = nanIndx(noValue);
        
        % Replace with next in Sobol Sequence
        newSampleRange = sobPoint:(sobPoint+nNans-1);
        mapLinIndx = sobol2indx(sobSet, newSampleRange, p.featureResolution, acqMap.edges);
        
        % Replace unreachable bins
        emptyCells = isnan(acqMap.fitness(mapLinIndx));
        while any(emptyCells)
            nEmptyCells = sum(emptyCells);
            mapLinIndx(emptyCells) = sobol2indx(sobSet,sobPoint:sobPoint+nEmptyCells-1, p.featureResolution, acqMap.edges);
            emptyCells = isnan(acqMap.fitness(mapLinIndx));
            sobPoint = sobPoint + nEmptyCells;
        end
        
        % Pull out chosen genomes from map
        [chosenI,chosenJ] = ind2sub(p.infill.featureResolution, mapLinIndx);
        for iGenes=1:nNans
            nextGenes(iGenes,:) = acqMap.genes(chosenI(iGenes),chosenJ(iGenes),:);
        end
        
        % Precise evaluation
        if ~isempty(nextGenes)
            measuredValue = feval(d.preciseEvaluate,nextGenes,d);
            % Assign found values
            newValue(nanIndx,:) = measuredValue;
        end
        
        if p.infill.retryInvalid
            % Check for invalid or duplicate shapes
            nanValue = any(isnan(newValue),2);
            oldDuplicate = logical(false(1,size(nanValue,1)));
            oldDuplicate(nanIndx) = any(pdist2(observation,nextGenes)==0);
            newDuplicate = logical(false(1,size(nanValue,1)));
            sampleDistances = pdist2(nextGenes,nextGenes);
            sampleDistances = sampleDistances + diag(ones(1,size(sampleDistances,1)));
            newDuplicate(nanIndx) = any(sampleDistances==0);
            noValue = nanValue | oldDuplicate' | newDuplicate';
        else
            % Do not try invalid shapes
	    inval = isnan(newValue(:,1));
	    disp(['Invalid shapes found: ' mat2str(newValue(inval,:))]);
            newValue(inval,:) = repmat([5],sum(inval),1);
	    disp(['Set to: ' mat2str(newValue(inval,:))]);
            % We still have to skip samples from empty bins
            noValue = any(isnan(nextGenes),2);
        end
        nextObservation(nanIndx,:) = nextGenes;         %#ok<AGROW>
        sobPoint = sobPoint + length(newSampleRange);   % Increment sobol sequence for next samples
    end
    
    % Add evaluated solutions to data set
    trueFitness = cat(1,trueFitness,newValue);
    observation = cat(1,observation,nextObservation);
    nSamples  = size(observation,1);
    
    % Assign new samples to parent pool as well
    parents = cat(1,parents,nextObservation);
    
    if p.display.illu% && (~mod(iGen,p.display.illuMod) || (iGen==p.nGens))
        visualizeStats(figHandleAcqMap,acqMap,d,nSamples);
    end
    
    fid = fopen('status.txt','wt');
    fprintf(fid, mat2str(fitness));
    fclose(fid);    

    save(filename,'observation','trueFitness');

end % end acquisition loop


% Create prediction map
disp(['PE ' int2str(nSamples) ' | Training Prediction Models']); 
p.infill.modelParams.functionEvals = 100;
modelPred = trainGP(observation,trueFitness,p.infill.modelParams);
p.featureResolution = p.predMapResolution;
[predMap] = createPredictionMap(modelPred,'mirror_AcquisitionFunc',p,d);

if p.display.illu
    viewMap(predMap,d)
end

end


function visualizeStats(figHandle,map,d,nSamples)
cla(figHandle);
caxis(figHandle,[0 max(map.fitness(:))]);
viewMap(map,d,figHandle);
title(figHandle,['Acquisition Fcn w. ' int2str(nSamples) ' samples']);
drawnow;
end
