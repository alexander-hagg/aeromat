function cD = mirror_OpenFoamResult(x, stlFileName, openFoamFolder, maxCD)
%mirror_openFoamResult - Evaluates a single shape in OpenFOAM 
%
% Syntax:  [observation, value] = af_InitialSamples(p)
%
% Inputs:
%    x              - Sample genome to evaluate
%    stlFileName    - Target to place expressed genome
%    openFoamFolder - OpenFOAM case folder
%
% Outputs:
%    cD  - [1X1] drag coefficient result for mirror
%

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: alexander.hagg@h-brs.de
% Jun 2017; Last revision: 09-Oct-2019

%------------- BEGIN CODE --------------
dragF = nan;
tTimeout = 30000;

% Create STL
stlwrite(stlFileName, x);

% Run SnappyHexMesh and OpenFOAM
[~,~] = system(['touch ' openFoamFolder 'start.signal']);

% Wait for results
resultOutputFile = [openFoamFolder 'postProcessing/forceCoeffs/0/coefficient.dat'];
tic;
while ~exist([openFoamFolder 'mesh.timing'] ,'file')
    display(['Waiting for Meshing: ' seconds2human(toc)]);
    pause(10);
    if (toc > tTimeout); cD = nan; return; end
end
display(['|----| Meshing done in ' seconds2human(toc)]);

tic;
while ~exist([openFoamFolder 'all.timing'] ,'file')
    display(['Waiting for CFD: ' seconds2human(toc)]);
    pause(10);
    if (toc > tTimeout); cD = nan; return; end
end
display(['|----| CFD done in ' seconds2human(toc)]);

if exist(resultOutputFile, 'file')
    display(resultOutputFile);
    raw = importdata(resultOutputFile);
    cD = mean(raw.data(end-99:end,2));
    if abs(cD) > maxCD
        disp(['|-------> Drag Coefficient calculated as ' num2str(cD) ' (returning 5)']);
        cD = 5; 
        save([openFoamFolder  'error' int2str(randi(1000,1)) '.mat'], 'x');
    end
    
else
    save([openFoamFolder  'error' int2str(randi(1000,1)) '.mat'], 'x');    
end

system(['touch ' openFoamFolder 'done.signal']);
%[~,~] = system(['(cd '   openFoamFolder '; ./Allclean)']);

