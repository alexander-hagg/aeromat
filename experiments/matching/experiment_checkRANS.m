clear;clc;
% ----------------------------------------------------------------------------------
disp(['>>> Configuration']);
DOMAIN              = 'mirror'; addpath(genpath(['/home/' getenv('USER') '/aeromat']));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain('nCases',4,'hpc',true,'username', getenv('USER'));

p                   = defaultParamSet;
p.infill            = infillParamSet;

dataDir = 'data/100InitialSamples';
[phenotype, validity, ffdP] = mirror_ffd_Express(0.5*ones(1,d.dof), 'mirrorBase.stl');
d.base = ffdP;

[F,target] = stlread([dataDir '/test_1.stl']);
[~,IDs] = unique(target(:,1)); % Somehow the STL files contain multiple instances of every node..
IDs = sort(IDs);
target = target(IDs,:);

dataFile = 'data/shapematching/mirrorShapeFitGetParameters.mat';
if exist(dataFile,'file')
    load(dataFile);
    disp(['Data loaded from file: ' dataFile]);
else    
    disp(['Cannot find data file: ' dataFile]);
end


%% Select 2 of worst and 2 of best fits to be run with RANS simulation

[minsort,minsortID] = sort(error,'ascend');
[maxsort,maxsortID] = sort(error,'descend');

selectedShapes = [minsortID(1:2),maxsortID(1:2)];
oldFitnesses = [minsort(1:2),maxsort(1:2)];
d.preciseEvaluate   = 'mirror_PreciseEvaluate';

%% Run OpenFoam

runTime = tic;

fitness = [];
fitness = feval(d.preciseEvaluate,params(selectedShapes,:),d); 
disp(['Runtime: ' seconds2human(toc(runTime))]);

% Save results
theseParams = params(selectedShapes,:);
save(['foamTest.mat'],'theseParams', 'fitness','oldFitnesses');










