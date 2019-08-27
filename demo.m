% demo - demo run SAIL
%
% Author: Adam Gaier, Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: adam.gaier@h-brs.de, alexander.hagg@h-brs.de
% Aug 2019; Last revision: 27-Aug-2019

%------------- BEGIN CODE --------------
%% Configuration
clear;clc;
DOMAIN              = 'npoly_ffd'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet(4);
p.infill            = infillParamSet;
surrogateAssistance = true;

initFilename = 'initialSamples.mat';
%d.preciseEvaluate = 'mirror_DummyPreciseEvaluate';

disp(['Initialization']);

if exist(initFilename,'file')
    [initSamples, fitness, values, phenotypes] = load(initFilename);
else
    sobSequence         = scramble(sobolset(d.dof,'Skip',1e3),'MatousekAffineOwen');
    sobPoint            = 1;
    initSamples         = range(d.ranges).*sobSequence(sobPoint:(sobPoint+p.numInitSamples)-1,:)+d.ranges(1);
end

[fitness,phenotypes]    = d.fitfun(initSamples,d); 

map                                 = createMap(d, p);
[replaced, replacement, features]   = nicheCompete(initSamples, fitness, phenotypes, map, d, p);
map                                 = updateMap(replaced,replacement,map,fitness,initSamples,features);

%% Main loop
[map,surrogate] = sail(map,d.fitfun,p,d);
viewMap(map,app.d{iter});

%%

%------------- END CODE --------------