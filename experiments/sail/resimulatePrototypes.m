%RESIMULATEPROTOTYPES - Run RANS or LES on selection of prototypes, save
% results
%
% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% dec 2017; Last revision: 14-Dec-2017

%------------- BEGIN CODE --------------

clear;clc;
nCases = str2num(getenv('NCASES'));if isempty(nCases); nCases=10; end
disp(['Running SAIL with ' int2str(nCases) ' parallel cases']);
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

%% Load prototype data 
load('aeromat.mat');
d.nCases = nCases; % Reset number of parallel OpenFOAM cases
fitness = feval(d.preciseEvaluate,prototypes.genomes,d); 
save(['prototypeTest.mat'],'fitness','d','prototypes');


