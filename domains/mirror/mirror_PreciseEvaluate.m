function [value,timings] = mirror_PreciseEvaluate(nextObservations, d)
%mirror_PreciseEvaluate - Send mirror shapes in parallel to OpenFOAM func
%
% Syntax:  [observation, value] = af_InitialSamples(p)
%
% Inputs:
%    nextObservations - [NX1] of parameter vectors
%    d                - domain description struct
%     .openFoamFolder 
%
% Outputs:
%    value(:,1)  - [nObservations X 1] drag force
%
% Other m-files required: mirror_openFoamResult

% Author: Adam Gaier, Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de, alexander.hagg@h-brs.de
% Jun 2017; Last revision: 27-Nov-2019

%------------- BEGIN CODE --------------
folderBaseName = d.openFoamFolder;

% Divide individuals to be evaluated by number of cases
nObs    = size(nextObservations,1);
nCases  = d.nCases;
nRounds = ceil(nObs/d.nCases);
caseStart = d.caseStart;

disp(nCases)

tic
value = nan(nObs,1);
timings = nan(nObs,1);
for iRound=0:nRounds-1
    PEValue = nan(nCases,1);
    % Evaluate as many samples as you have cases in a batch
    parfor iCase = 1:nCases
        disp(iCase)
        obsIndx = iRound*nCases+iCase;          
        if obsIndx <= nObs
            openFoamFolder = [folderBaseName 'case' int2str(iCase+caseStart-1) '/']
            PEValue(iCase) = mirror_OpenFoamResult(...
               d.express(nextObservations(obsIndx,:)),...
               [openFoamFolder 'constant/triSurface/test.stl'],...
               openFoamFolder, ...
               d.maxCD);
        end
    end  
    
    % -log(cD) to allow maximization
    PEValue = -log(PEValue);
    
    timings(iRound+1) = toc;
    disp(['Round ' int2str(iRound) ' -- Time so far ' seconds2human(timings(iRound+1))])
    % Assign results of batch 
    obsIndices = 1+iRound*nCases:nCases+iRound*nCases;
    filledIndices = obsIndices(obsIndices<=nObs);
    value(filledIndices) = PEValue(1:length(filledIndices));
end

%------------- END OF CODE --------------
