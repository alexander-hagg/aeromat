% sailMirror_RANSvsLES_noModelUpdates
% 
% Description:
% This first experiment will use a surrogate model that is trained on 100 
% initial CFD results to generate a quality diversity feature map. The model 
% will not be updated. 
%
% Expected result:
% 
%
% Author: Adam Gaier, Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: adam.gaier@h-brs.de, alexander.hagg@h-brs.de
% Aug 2019; Last revision: 29-Aug-2019

%------------- BEGIN CODE --------------
clear;clc;
nCases = str2num(getenv('NCASES'));if isempty(nCases); nCases=1; end
homeDir = getenv('HOME');
userName = getenv('USER');
repositoryLocation = getenv('repositoryFolderName'); if isempty(repositoryLocation); repositoryLocation = '.'; end
jobLocation = getenv('destFolderName');
runOncluster = true;

cfdSolver = getenv('cfdSolver'); if isempty(cfdSolver); cfdSolver = 'LES_COMPRESSIBLE'; end % 'RANS_INCOMPRESSIBLE' 'LES_COMPRESSIBLE'

% ----------------------------------------------------------------------------------
DOMAIN              = 'mirror'; addpath(genpath(repositoryLocation));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain('nCases',nCases,'hpc',runOncluster,'userName',userName,'cfdSolver',cfdSolver,'jobLocation',jobLocation);
p                   = defaultParamSet;
p.infill            = infillParamSet;
surrogateAssistance = true;

p.infill.nTotalSamples        = 100;

% ----------------------------------------------------------------------------------
disp(['>>> Load initial data']);
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
disp(['>>> Illumination']);

p.display.illu = false
tic
[map,surrogate] = sail(initmap,p,d,initSamples,fitness);
toc

save('data/LESvsRANS_noSampling/LES2.mat','map','surrogate','initmap','initSamples','fitness');
figure(2)
viewMap(map,d);

%------------- END CODE --------------
