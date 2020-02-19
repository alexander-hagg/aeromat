clear;clc;
nCases = str2num(getenv('NCASES'));if isempty(nCases); nCases=1; end
disp(['Running SAIL with ' int2str(nCases) ' parallel cases']);
homeDir = getenv('HOME');
userName = getenv('USER');
repositoryLocation = getenv('REPOSITORYLOCATION'); if isempty(repositoryLocation); repositoryLocation = '.'; end
jobLocation = getenv('JOBLOCATION');
cfdSolver = getenv('CFDSOLVER'); if isempty(cfdSolver); cfdSolver = 'RANS_INCOMPRESSIBLE'; end % 'RANS_INCOMPRESSIBLE' 'LES_COMPRESSIBLE'
runOncluster = true;

DOMAIN              = 'mirror'; addpath(genpath(repositoryLocation));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain('nCases',nCases,'hpc',runOncluster,'userName',userName,'cfdSolver',cfdSolver,'jobLocation',jobLocation);
p                   = defaultParamSet;
p.infill            = infillParamSet;
surrogateAssistance = true;

mutation = 0.5*rand(1,d.dof);
[FV, ~, ffdP] = mirror_ffd_Express(mutation, 'mirrorBase.stl');

figure(1); hold off;
h = visPhenotype(FV,FV.controlPtsScaled)
view(70,30);
axis([-100 100 -200 200 600 800]);    

%% Create mirrors from Sobol set
p.numInitSamples = 100;
sobSequence                         = scramble(sobolset(d.dof,'Skip',1e3),'MatousekAffineOwen');
samples                             = sobSequence(1:(1+p.numInitSamples)-1,:);


for i=1:p.numInitSamples
    %[FV, ~, ffdP] = mirror_ffd_Express(0.5*ones(1,d.dof), 'mirrorBase.stl');
    [FV, ~, ffdP] = mirror_ffd_Express(samples(i,:), 'mirrorBase.stl');
    stlwrite(['test_' int2str(i) '.stl'],FV);

%    view(90,0);
%    axis([-100 100 -200 200 600 800]);   
%    pause(0.5);
end