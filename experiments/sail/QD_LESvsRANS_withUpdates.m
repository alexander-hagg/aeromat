% sailMirror_RANSvsLES_noModelUpdates
% 
% Description:
% This experiment uses a surrogate model that is trained on 100 
% initial CFD results to generate a quality diversity feature map. The model 
% will then be updated using Upper Confidence Bound sampling.
%
%
% Author: Adam Gaier, Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: adam.gaier@h-brs.de, alexander.hagg@h-brs.de
% Aug 2019; Last revision: 15-Oct-2019

%------------- BEGIN CODE --------------
clear;clc;
nCases = str2num(getenv('NCASES'));if isempty(nCases); nCases=1; end
disp(['Running SAIL with ' int2str(nCases) ' parallel cases']);
homeDir = getenv('HOME');
userName = getenv('USER');
repositoryLocation = getenv('REPOSITORYLOCATION'); if isempty(repositoryLocation); repositoryLocation = '.'; end
jobLocation = getenv('JOBLOCATION');
cfdSolver = getenv('CFDSOLVER'); if isempty(cfdSolver); cfdSolver = 'LES_INCOMPRESSIBLE'; end % 'RANS_INCOMPRESSIBLE' 'LES_COMPRESSIBLE'
runOncluster = true;

% ----------------------------------------------------------------------------------
DOMAIN              = 'mirror'; addpath(genpath(repositoryLocation));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain('nCases',nCases,'hpc',runOncluster,'userName',userName,'cfdSolver',cfdSolver,'jobLocation',jobLocation);
p                   = defaultParamSet;
p.infill            = infillParamSet;
surrogateAssistance = true;

%% FOR TESTING ONLY
% disp('>>> !!! Testing parameters are on!')
% d.preciseEvaluate = 'mirror_DummyPreciseEvaluate';
% p.nGens = 25;
% p.infill.nAdditionalSamples = 10;
%%

% ----------------------------------------------------------------------------------
disp('>>> Load latest data (either from initial sampling or latest experiment');

candidateDataFiles = dir([repositoryLocation '/data/QD_LESvsRANS_withUpdates/']);
candidateDataFiles = candidateDataFiles(3:end);

lastDataFileID = 0;
dataFile = '';
for i=1:length(candidateDataFiles)
    if ~isempty(strfind(candidateDataFiles(i).name,cfdSolver)) 
        k = strfind(candidateDataFiles(i).name,cfdSolver);
        id = candidateDataFiles(i).name(k + length(cfdSolver) + 1);
        id = str2num(id);
        if id > lastDataFileID
            dataFile = candidateDataFiles(i).name;
            lastDataFileID = id;
        end
    end
end

if ~exist(dataFile,'file')
    % If no data is found, load data from initial sampling experiment
    load('data/initSetParamsAndFitness.mat');
    initSamples = mirrorParams;
    if strcmp(cfdSolver,'RANS_INCOMPRESSIBLE')
        fitness = -log(cD_RANSinc);
    elseif strcmp(cfdSolver,'LES_COMPRESSIBLE')    
        fitness = -log(cD_LEScom);
    end
    save([repositoryLocation '/data/QD_LESvsRANS_withUpdates/init.mat'],'initSamples','fitness');
else
    load(dataFile);
    initSamples = surrogate.trainInput;
    fitness = surrogate.trainOutput;
end
disp(['Running SAIL based on data file: ' dataFile]);
disp(['Number of samples: ' int2str(length(fitness))]);

numSamplesPerExperiment = 50;
p.numInitSamples = size(initSamples,1);
p.infill.nTotalSamples = p.numInitSamples + numSamplesPerExperiment;

initmap                                             = createMap(d, p);
[replaced, replacement, percImprovement, features]  = nicheCompete(initSamples, fitness, initmap, d, p);
initmap                                             = updateMap(replaced,replacement,initmap,fitness,initSamples,features);

%% ----------------------------------------------------------------------------------
disp('>>> Illumination');
p.display.illu = false;

filename = [repositoryLocation '/data/QD_LESvsRANS_withUpdates/' cfdSolver '_' int2str(lastDataFileID+1)];

[map,surrogate] = sail(initmap,p,d,initSamples,fitness,[filename '_sail' '.mat']);

save([filename '_finished' '.mat'],'map','surrogate','initmap','initSamples','fitness');
disp('>>> Finished');

% viewMap(map,d);

%------------- END CODE --------------
