% sail_Mirror_RANSIncompressible
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
repositoryLocation = getenv('repositoryFolderName');
foamTemplateLocation = getenv('templateFolderName');
runOncluster = true;

% ----------------------------------------------------------------------------------
disp(['>>> Configuration']);
DOMAIN              = 'mirror'; addpath(genpath(repositoryLocation));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain('nCases',nCases,'hpc',runOncluster,'homeDir',homeDir,'userName',userName,'foamTemplate',foamTemplateLocation);
p                   = defaultParamSet(4);
p.infill            = infillParamSet;
surrogateAssistance = true;

% uncomment this for real evaluation
% d.preciseEvaluate = 'mirror_DummyPreciseEvaluate';

% ----------------------------------------------------------------------------------
disp(['>>> Initialization']);
if exist(d.initialSampleSource,'file')
    [initSamples, values] = load(initFilename);
else
    sobSequence         = scramble(sobolset(d.dof,'Skip',1e3),'MatousekAffineOwen');
    sobPoint            = 1;
    initSamples         = range(d.ranges).*sobSequence(sobPoint:(sobPoint+p.numInitSamples)-1,:)+d.ranges(1);
    fitness             = feval(d.preciseEvaluate,initSamples,d); 
end

map                                                 = createMap(d, p);
[replaced, replacement, percImprovement, features]  = nicheCompete(initSamples, fitness, map, d, p);
map                                                 = updateMap(replaced,replacement,map,fitness,initSamples, features);

% ----------------------------------------------------------------------------------
disp(['>>> Illumination']);
[map,surrogate] = sail(map,p,d);
%viewMap(map,d);

%------------- END CODE --------------