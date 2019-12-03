function d = domain(varargin)
%domain - mirror Domain Parameters
% Returns struct with default for all settings of a car mirror domain
% including hyperparameters, and strings indicating functions for
% representation and evaluation. Direct parameter or free form deformation
% encodings can be chosen.
%
% Syntax:  d = domain('encoding',ENCODING,'nCases',NCASES);
%
% Example:
%    d = domain('encoding','ffd'  ,'nCases',10)
%    output = sail(sail,d);
%    d = domain('encoding','param','nCases',2)
%    output = sail(sail,d);
%
%
% See also: sail, runSail

% Author: Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: alexander.hagg@h-brs.de
% Dec 2017; Last revision: 11-Dec-2017
%
%------------- Input Parsing ------------
parse = inputParser;
parse.addOptional('nCases'  , 1);
parse.addOptional('hpc', true);
parse.addOptional('userName','ahagg2s');
parse.addOptional('jobLocation','/scratch/ahagg2s/sailCFD/');
parse.addOptional('cfdSolver','RANS_INCOMPRESSIBLE'); % 'RANS_INCOMPRESSIBLE' 'LES_COMPRESSIBLE'

parse.parse(varargin{:});
d.nCases      = parse.Results.nCases;
d.hpc         = parse.Results.hpc;
d.userName    = parse.Results.userName;
d.jobLocation = parse.Results.jobLocation;
d.cfdSolver      = parse.Results.cfdSolver;

d.repo = ['/home/' d.userName '/aeromat'];

%%------------- BEGIN CODE --------------
disp(['Mirror domain']);
% Ensure Randomness of Randomness
RandStream.setGlobalStream(RandStream('mt19937ar','Seed','shuffle'));

d.name = 'mirror_ffd';

% - Scripts
% Common to any representations
d.preciseEvaluate   = 'mirror_PreciseEvaluate';    %
d.categorize        = 'mirror_Categorize';         %
d.createAcqFunction = 'mirror_CreateAcqFunc';      %
d.validate          = [d.name '_Validate'];

% - Genotype to Phenotype Expression
% Any representation should produce a fv struct and NX3 meshpoints
d.dof = 36; disp(['Degrees of freedom: ' int2str(d.dof)]);
base = 0.5+zeros(1,d.dof);
d.ranges = [0 1];

% Acquisition function
d.varCoef  = 10; % variance weight


% Base mesh for free form deformation
[~, ~, d.FfdP] =  mirror_ffd_Express(base,'domains/mirror/ffd/mirrorBase.stl');
d.express  = @(x) mirror_ffd_Express(x, d.FfdP);
[~, ~, d.FfdP_CFD] =  mirror_ffd_Express(base,'domains/mirror/ffd/mirrorBase_CFD.stl');
d.express_CFD  = @(x) mirror_ffd_Express(x, d.FfdP_CFD);
d.base.fv   = d.express(base);
d.base.mesh = d.base.fv.vertices;

% - Alternative initialization [ TODO ]
d.loadInitialSamples = false;
d.initialSampleSource= '#notallFfdmirrors.mat';

% - Feature Space
% Map borders
d.featureLabels = {'RelativeLengthX', 'RelativeLengthY'};
d.featureSelection = [1 2]; % Default selection (Total Curvature and Relative Length)
d.extraMapValues = {'dragCoefficient'};

%% Features (domain specific)
%   Feature Borders
%d.featureMin = [0.1  90  0];
%d.featureMax = [1.5  180 40000];
d.featureMin = [100   150];
d.featureMax = [150  250];

d.featureMin = d.featureMin(d.featureSelection);
d.featureMax = d.featureMax(d.featureSelection);

% IDs of changeable vertices of base mesh
%load('baseSubMeshIds.mat');d.features.subMeshIds = baseSubMeshIds;clear baseSubMeshIds;
% Vertice IDs of lines on which curvature is measured
load('verticeIDs.mat');d.features.curvature.ids = verticeIDs;clear verticeIDs;
% Reflective Surface
load('mirrorIDs.mat');d.features.mirror.ids = mirrorIDs;clear mirrorIDs;

% - Visualization
color8 = parula(8);
d.view = @(x) patch('Faces',x.faces,'Vertices',x.vertices,...
    'FaceColor',color8(3,:),'FaceAlpha',0.35);

%% Precise Evaluation
d.caseStart = 1;
d.nVals = 1;                    % # of values of interest, e.g. dragForce (1), or cD and cL (2)
d.maxCD = 10;                   % Only use this to prevent really bad shapes to influence the surrogate model

if d.hpc
    %% Cluster
    % % Cases are executed and stored here (cases are started elsewhere)
    d.openFoamFolder = d.jobLocation;
    d.openFoamTemplate = [d.repo '/domains/mirror/pe/ofTemplates/' d.cfdSolver];  
    % - There should be a folder called 'case1, case2, ..., caseN in this
    % folder, where N is the number of new samples added every iteration.
    % - Each folder has a shell script called 'caserunner.sh' which must be
    % run, this will cause an instance of openFoam to run whenever a signal is
    % given (to allow jobs to be run on nodes with minimal communication).
    
else
    %% Local
    disp('Local run not available!');
    d.openFoamFolder = d.jobLocation;
    d.openFoamTemplate = [d.repo '/domains/mirror/pe/ofTemplates/' d.cfdSolver];  
    
    %% Cases are executed and stored here
    d.caseRunner = [d.repo '/domains/mirror/pe/startCaseRunners.sh'];
    disp(['Creating folder ' d.openFoamFolder]);
    mkdir(d.openFoamFolder);
    disp(['Copying necessary files to ' d.openFoamFolder]);
    system(['cp ' d.caseRunner ' ' d.openFoamFolder]);
    for iCase = 1:d.nCases
        system(['rm -rf ' d.openFoamFolder 'case' int2str(iCase)]);
        system(['mkdir ' d.openFoamFolder 'case' int2str(iCase)]);
        system(['cp -r ' d.openFoamTemplate '/* ' d.openFoamFolder 'case' int2str(iCase)]);
        system(['cp ' d.caseRunner ' ' d.openFoamFolder ]);
    end
end




% %------------- END OF CODE --------------






