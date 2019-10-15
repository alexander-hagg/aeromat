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
homeDir = getenv('HOME');
userName = getenv('USER');
repositoryLocation = getenv('REPOSITORYLOCATION'); if isempty(repositoryLocation); repositoryLocation = '.'; end
jobLocation = getenv('JOBLOCATION');
cfdSolver = getenv('CFDSOLVER'); if isempty(cfdSolver); cfdSolver = 'RANS_INCOMPRESSIBLE'; end % 'RANS_INCOMPRESSIBLE' 'LES_COMPRESSIBLE'
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
disp('>>> Load initial data');
load('data/initSetParamsAndFitness.mat');
initSamples = mirrorParams;
if strcmp(cfdSolver,'RANS_INCOMPRESSIBLE')
    fitness = -log(cD_RANSinc);
elseif strcmp(cfdSolver,'LES_COMPRESSIBLE')    
    fitness = -log(cD_LEScom);
end

initmap                                             = createMap(d, p);
[replaced, replacement, percImprovement, features]  = nicheCompete(initSamples, fitness, initmap, d, p);
initmap                                             = updateMap(replaced,replacement,initmap,fitness,initSamples,features);

%% ----------------------------------------------------------------------------------
disp('>>> Illumination');
p.display.illu = false;
[map,surrogate] = sail(initmap,p,d,initSamples,fitness);

save(['data/QD_LESvsRANS_withUpdates/' cfdSolver '.mat'],'map','surrogate','initmap','initSamples','fitness');
disp('>>> Finished');

% viewMap(map,d);

%------------- END CODE --------------
