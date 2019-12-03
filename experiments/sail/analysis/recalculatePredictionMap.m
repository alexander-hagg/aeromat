DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;
p                   = defaultParamSet;

load('RANS_INCOMPRESSIBLE_3.mat');


%%
d.featureMax(2) = 140;
p.featureResolution = [50 50];
[predMap] = createPredictionMap(surrogate,'mirror_AcquisitionFunc',p,d);
