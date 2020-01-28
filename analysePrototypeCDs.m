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
%% Get Ground Truth

simulations = {'RANS','LES'};
protSrcLabels = [1, 1, 2, 2, 2, 2, 2, 1, 1, 1];
for si=1:length(simulations)
    for i=1:10
        data = importdata([simulations{si} int2str(i)]);
        cD(si,i) = mean(data.data(end-99:end,2));
    end
end

%% Get model predictions
load('aeromat.mat');

predRANS = feval('predictGP', resultsRANS.surrogate, prototypes.genomes);
predLES = feval('predictGP', resultsLES.surrogate, prototypes.genomes);

predRANS = exp(-predRANS);
predLES = exp(-predLES);

%%

fig(1) = figure(1); hold off;
plot(cD(1,:)','r.');
hold on;
plot(cD(2,:)','b.');
plot(predRANS(:,1)','ro');
plot(predLES(:,1)','bo');
plot(ones(1,10),'k-');

legend('RANS GT','LES GT', 'RANS Prediction', 'LES Prediction', 'Prediction Model Default Mean');
xlabel('Solver used to find prototype');
ylabel('cD');
axis([0.5 10.5 0 1.5]);
grid on;

title('Prediction and Ground Truth (GT) Values of Prototypes');

ax = gca;
ax.XTick = [1:10];
ax.XTickLabels = {simulations{protSrcLabels}};
save_figures(fig, '.', 'cDPrototypes', 12, [10 5])

%% Show maps and prototype locations

features_prot = mirror_Categorize(prototypes.genomes, d) * p.featureResolution(1);

load('aeromat.mat');
resultsRANS.map.fitness = exp(-resultsRANS.map.fitness);
[figHandle, imageHandle,cHandle] = viewMap(resultsRANS.map,d);
cmap = parula(8); cmap(end,:) = [];
colormap(figHandle,cmap);
cHandle = colorbar;
%caxis([0.3 0.6]);

scatter(features_prot(protSrcLabels==1,1),features_prot(protSrcLabels==1,2),32,'r','filled') %RANS
scatter(features_prot(protSrcLabels==2,1),features_prot(protSrcLabels==2,2),32,'r') %LES
title('Predicted Fitness RANS Optimization');
fig(1) = gcf;
axis([0.5 50.5 0.5 50.5]);


resultsLES.map.fitness = exp(-resultsLES.map.fitness);
[figHandle, imageHandle,cHandle] = viewMap(resultsLES.map,d)
colormap(figHandle,cmap);
cHandle = colorbar(figHandle);
%caxis([0.3 0.6]);

scatter(features_prot(protSrcLabels==1,1),features_prot(protSrcLabels==1,2),32,'r') %RANS
scatter(features_prot(protSrcLabels==2,1),features_prot(protSrcLabels==2,2),32,'r','filled') %LES
title('Predicted Fitness LES Optimization');
fig(2) = gcf;
axis([0.5 50.5 0.5 50.5]);


save_figures(fig, '.', 'mapsWithPrototypes', 12, [10 5])


