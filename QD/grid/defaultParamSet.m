function p = defaultParamSet()
% defaultParamSet - loads default parameters for QD algorithm 
% (here: MAP-Elites with grid archive)
%
% Syntax:  p = defaultParamSet()
%               
%
% Outputs:
%   p      - struct - QD configuration struct
%
% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de
% Nov 2018; Last revision: 15-Aug-2019
%
%------------- BEGIN CODE --------------

p.numInitSamples            = 100;      % number of initial samples
p.nGens                     = 2^12;       % number of generations
p.nChildren                 = 2^7;      % number of children per generation
p.mutSigma                  = 0.1;      % mutation drawn from Gaussian distribution with this \sigma
p.featureResolution         = [50,50];  % Resolution of the map (in cells per dimension). Keep it square
p.extraMapValues            = {'fitnessAdjustment','drift'}; % extra map values used in map struct
p.convergeLimit             = 0.05;

% Selection
p.penaltyWeight             = 2;        % User selection drift, weight for soft constraints
p.driftThreshold            = 0.5;      % User selection drift, threshold for hard user constraint

% Visualization and management of saved data 
p.display.illu              = false;
p.display.illuMod           = 100;
p.numMaps2Save              = 100;

end

%------------- END CODE --------------
