% %% FFD - Adapted from PyGeM
% TODO: Proper header and documentation

% Author: Adam Gaier, Alexander Hagg
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de, alexander.hagg@h-brs.de
% Dec 2017; Last revision: 22-Mar-2019

function [FV, validity, ffdP] = mirror_ffd_Express(deformValsUnlimited, base)
% meshPoints - original foil points and should be input for general use
% deformParams

validity = true; % Do we really need to check anything?
visualize = false;
deformVals = (deformValsUnlimited)-0.5;
nDeforms = size(deformVals,1);
doRotation = true; % Always true if real experiments are run

if ischar(base);    precomputed = false; fname= base;
else;               precomputed = true;  ffdP = base;
end

%% General Calculations (result saved for speed up)
if ~precomputed
    rawStl = stlread(fname);
    % Recenter mesh
    rawStl.vertices(:,1:2) = rawStl.vertices(:,1:2) - mean(rawStl.vertices(:,1:2));
    [STLMeshpoints,faces] = patchslim(rawStl.vertices, rawStl.faces);

        % Rotate mesh to align with bounding box
    if doRotation
        theta           = atan((0.83-0.45)/1.28);
        rotMat          = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
        deRotMat        = [cos(-theta) -sin(-theta) 0; sin(-theta) cos(-theta) 0; 0 0 1];        
        STLMeshpoints   = STLMeshpoints * rotMat;
    end
    
    % Normalize mesh points
    [STLMeshpoints,normalizationFactors] = mapminmax(STLMeshpoints',-1,1);
    STLMeshpoints = STLMeshpoints';
    %scatter3(STLMeshpoints(:,1),STLMeshpoints(:,2),STLMeshpoints(:,3));view(0,90);

    
    %% Define bounding box
    maxY = 2.0; % OLD VERSION maxY = 0.4;
    
    % Select mesh points within bounding box
    submesh         = (STLMeshpoints(:,2) + 0.37*STLMeshpoints(:,1))< maxY;
    meshPoints      = STLMeshpoints(submesh,:);
    nMeshPoints     = size(meshPoints,1);
    
    % Translate and rescale bounding box to "unit bounding box", because we
    % assume that the control points are on a unit lattice
    minMeshPoint = min(meshPoints);
    maxMeshPoint = max(meshPoints);
    meshPoints = (meshPoints - repmat(minMeshPoint,size(meshPoints,1),1))./repmat((maxMeshPoint-minMeshPoint),size(meshPoints,1),1);
    
    % Direction of each active control point in each dimension
    nDimX = 4; nDimY = 4; nDimZ = 3;
    
    x = zeros([nDimY,nDimZ,nDimX]);
    y = zeros([nDimY,nDimZ,nDimX]);
    z = zeros([nDimY,nDimZ,nDimX]);
    fullMovement = [ -1,   -1,  -1
                      0,    0,   0
                      0,    0,   0
                      0,    0,   0];
    
    x(:,:,1) = fullMovement;
    x(:,:,2) = fullMovement;
    x(:,:,3) = fullMovement;
    x(:,:,4) = fullMovement;
    y(:,:,1) = fullMovement;
    y(:,:,2) = fullMovement;
    y(:,:,3) = fullMovement;
    y(:,:,4) = fullMovement;
    z(:,:,1) = fullMovement;
    z(:,:,2) = fullMovement;
    z(:,:,3) = fullMovement;
    z(:,:,4) = fullMovement;
    %disp(['DOF calc: ' int2str(sum(logical(abs(x(:)))+logical(abs(y(:)))+logical(abs(z(:)))))]);
    
    allDefs = cat(4,x,y,z);
    
    % Indexes of active dimensions
    ffdDof = find(allDefs(:)~=0);
    
    % Map the _parameters_ to the _degrees of freedom_ (3 per control point)
    % Without constraints (like symmetry), it is just a 1:1 mapping
    % HINT: 1:1 mapping:      defValKey = 1:length(deformVals);
    defValKey = 1:length(deformVals);
    
    % HINT: you can also use the following visualization to see what DoF is
    % where
    IDs = 1:length(allDefs(:));
    controlPtsX = 0:1/(nDimX-1):1;controlPtsY = 0:1/(nDimY-1):1;controlPtsZ = 0:1/(nDimZ-1):1;
    controlPts = combvec(controlPtsY,controlPtsZ,controlPtsX);
    controlPts = [controlPts(3,:);controlPts(2,:);controlPts(1,:)];
 
    %% Compute Bernstein polynomials
    % These won't change if we keep deforming the same shape, so we can
    % save the results and skip all the computation in later runs.
    
    % Preallocate
    bernstein_x = zeros(nDimX,nMeshPoints);
    bernstein_y = zeros(nDimY,nMeshPoints);
    bernstein_z = zeros(nDimZ,nMeshPoints);
    shift_mesh_points = zeros(size(meshPoints));
    
    % Compute Bernstein polynomials
    for i = 1:nDimX
        aux1 = (1-meshPoints(:,1)) .^(nDimX-i);
        aux2 = (  meshPoints(:,1)) .^(i-1);
        bernstein_x(i,:) = nchoosek(nDimX-1, i-1) .* (aux1' .* aux2');
    end
    
    for i = 1:nDimY
        aux1 = (1-meshPoints(:,2)) .^(nDimY-i);
        aux2 = (  meshPoints(:,2)) .^(i-1);
        bernstein_y(i,:) = nchoosek(nDimY-1, i-1) .* (aux1' .* aux2');
    end
    
    for i = 1:nDimZ
        aux1 = (1-meshPoints(:,3)) .^(nDimZ-i);
        aux2 = (  meshPoints(:,3)) .^(i-1);
        bernstein_z(i,:) = nchoosek(nDimZ-1, i-1) .* (aux1' .* aux2');
    end
    
    %% Save Precomputable
    ffdP.faces   = faces;
    ffdP.allDefs = allDefs;
    ffdP.defValKey = defValKey;
    ffdP.ffdDof = ffdDof;
    ffdP.mesh_points = meshPoints;
    ffdP.nDimX = nDimX;
    ffdP.bernstein_x = bernstein_x;
    ffdP.nDimY = nDimY;
    ffdP.bernstein_y = bernstein_y;
    ffdP.nDimZ = nDimZ;
    ffdP.bernstein_z = bernstein_z;
    ffdP.nonTransformedPoints = STLMeshpoints;
    ffdP.controlPts = controlPts;
    ffdP.submesh = submesh;
    if doRotation
        ffdP.rotMat = rotMat;
        ffdP.deRotMat = deRotMat;
        ffdP.theta = theta;
    end
    ffdP.normalizationFactors = normalizationFactors;
    ffdP.maxMeshPoint = maxMeshPoint;ffdP.minMeshPoint = minMeshPoint;
    ffdP.shift_mesh_points = shift_mesh_points;
    ffdP.unpack  = 'names = fieldnames(ffdP); for i=1:length(names) eval( [names{i},''= ffdP.'', names{i}, '';''] ); end';
else
    %     eval(ffdP.unpack); % It takes twice as long to evaluate this string
    %                        % then just run this stuff below
    faces               = ffdP.faces;
    allDefs             = ffdP.allDefs;
    defValKey           = ffdP.defValKey ;
    ffdDof              = ffdP.ffdDof;
    meshPoints          = ffdP.mesh_points;
    nDimX               = ffdP.nDimX;
    bernstein_x         = ffdP.bernstein_x ;
    nDimY               = ffdP.nDimY;
    bernstein_y         = ffdP.bernstein_y;
    nDimZ               = ffdP.nDimZ;
    bernstein_z         = ffdP.bernstein_z;
    STLMeshpoints       = ffdP.nonTransformedPoints;
    controlPts          = ffdP.controlPts;
    submesh = ffdP.submesh;
    if doRotation
        rotMat = ffdP.rotMat;
        deRotMat = ffdP.deRotMat;
        theta = ffdP.theta;
    end
    normalizationFactors = ffdP.normalizationFactors;
    maxMeshPoint = ffdP.maxMeshPoint; minMeshPoint = ffdP.minMeshPoint;
    shift_mesh_points   = ffdP.shift_mesh_points;
end

%% Deformation Parameter Specific Calculations
def(:,1:nDeforms) = deformVals(1:nDeforms,defValKey(:))';

allDeforms = permute(repmat(allDefs,[1 1 1 1 nDeforms]),[5 1 2 3 4]);
allDeforms(1:nDeforms,ffdDof) = allDeforms(1:nDeforms,ffdDof).*def(:,1:nDeforms)';

% Calculate shifts
aux_x = zeros(nDeforms,1); aux_y = aux_x;  aux_z = aux_x;
for j = 1:nDimY
    for k = 1:nDimZ
        bernstein_yz = bernstein_y(j,:) .* bernstein_z(k,:);
        for i = 1:nDimX
            aux = bernstein_x(i,:) .* bernstein_yz;
            aux_x = aux_x + aux .* allDeforms(:, j, k, i, 1);
            aux_y = aux_y + aux .* allDeforms(:, j, k, i, 2);
            aux_z = aux_z + aux .* allDeforms(:, j, k, i, 3);
            
            % Change control points for visualization purposes
            controlPtsDeform(:,i*k*j) = squeeze(allDeforms(:, j, k, i, :));
        end
    end
end

all_smp = permute(repmat(shift_mesh_points,[1,1,nDeforms]),[3 1 2]);
all_smp(:,:,1) = all_smp(:,:,1) + aux_x;
all_smp(:,:,2) = all_smp(:,:,2) + aux_y;
all_smp(:,:,3) = all_smp(:,:,3) + aux_z;

% Apply shifts and unscale
all_mp = permute(repmat(meshPoints,[1,1,nDeforms]),[3 1 2]);
newMeshPoints = all_mp + all_smp;

all_ctl = permute(repmat(zeros(size(controlPts,2),3),[1,1,nDeforms]),[3 1 2]);
all_ctl(:,:,1) = all_ctl(:,:,1) + controlPtsDeform(1,:);
all_ctl(:,:,2) = all_ctl(:,:,2) + controlPtsDeform(2,:);
all_ctl(:,:,3) = all_ctl(:,:,3) + controlPtsDeform(3,:);

% Apply shifts and unscale
all_mp = permute(repmat(controlPts',[1,1,nDeforms]),[3 1 2]);
newControlPts = all_mp + all_ctl;
newControlPts = squeeze(newControlPts);



%% Save as faces and vertices
for iDeforms = 1:nDeforms
    FV(iDeforms).faces = faces;
    STLMeshpoints(submesh,:) = squeeze(newMeshPoints(iDeforms,:,:));
    
    %% Descaling, rotation and denormalization
    % Descaling
    STLMeshpoints(submesh,:) = STLMeshpoints(submesh,:).*repmat((maxMeshPoint-minMeshPoint),sum(submesh),1) + repmat(minMeshPoint,sum(submesh),1);
    controlPtsScaled = newControlPts.*repmat((maxMeshPoint-minMeshPoint),size(ffdP.controlPts,2),1) + repmat(minMeshPoint,size(ffdP.controlPts,2),1);
    % Rotate back
    if doRotation
        STLMeshpoints = STLMeshpoints * deRotMat;
        controlPtsScaled = controlPtsScaled * deRotMat;
    end
    % Denormalize mesh points
    newMeshPoints_denorm = repmat(normalizationFactors.xmin,1,size(STLMeshpoints,1)) + (STLMeshpoints'-normalizationFactors.ymin).*repmat(normalizationFactors.xrange,1,size(STLMeshpoints,1))./normalizationFactors.yrange;
    controlPtsScaled = repmat(normalizationFactors.xmin,1,size(controlPtsScaled,1)) + (controlPtsScaled'-normalizationFactors.ymin).*repmat(normalizationFactors.xrange,1,size(controlPtsScaled,1))./normalizationFactors.yrange;
    
    
    FV(iDeforms).vertices = newMeshPoints_denorm;
    FV(iDeforms).controlPtsScaled = controlPtsScaled;
end

ffdP.allDeforms = allDeforms;
