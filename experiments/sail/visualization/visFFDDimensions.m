DOMAIN              = 'mirror'; addpath(genpath('.'));rmpath(genpath('domains')); addpath(genpath(['domains/' DOMAIN]));
d                   = domain;

set(0,'DefaultFigureWindowStyle','default');
nGenomes = 3;
cmap = parula(nGenomes);
initGenes = 0.5*ones(1,d.dof);
deltas = -0.5:(1/(nGenomes-1)):0.5;

pointSize = 1;
skip = 2;
alpha = 1;

for position=1:d.dof
    
    clear FV;
    for i=1:nGenomes
        perturb = zeros(1,d.dof);
        perturb(position) = deltas(i);
        [FV{i}, ~, ffdP] = mirror_ffd_Express(initGenes+perturb, 'mirrorBase.stl');
        disp(i)
    end
    
    fig(position) = figure(position);hold off;
    %subplot(ceil(sqrt(d.dof)),ceil(sqrt(d.dof)),position);hold off;
    hold off;
    
    for i=1:length(FV)
        vX = FV{i}.vertices(1,:);
        vY = FV{i}.vertices(2,:);
        vZ = FV{i}.vertices(3,:);
        subplot(1,3,1);
        h(i) = scatter3(vX(1:skip:length(vX)),vY(1:skip:length(vX)),vZ(1:skip:length(vX)),pointSize,cmap(i,:),'filled','MarkerFaceAlpha',alpha);
        hold on;
        drawnow;
        view(0,90);axis equal;
        axis([-80 80 -150 150 600 800]);
        title(['FFD dim. ' int2str(position) '/' int2str(d.dof)]);
        
        subplot(1,3,2);
        scatter3(vX(1:skip:length(vX)),vY(1:skip:length(vX)),vZ(1:skip:length(vX)),pointSize,cmap(i,:),'filled','MarkerFaceAlpha',alpha);
        hold on;
        drawnow;
        view(0,0);axis equal;
        axis([-80 80 -150 150 600 800]);
        
        subplot(1,3,3);
        scatter3(vX(1:skip:length(vX)),vY(1:skip:length(vX)),vZ(1:skip:length(vX)),pointSize,cmap(i,:),'filled','MarkerFaceAlpha',alpha);
        hold on;
        drawnow;
        view(90,0);axis equal;
        axis([-80 80 -150 150 600 800]);
        
        disp([int2str(i) '/' int2str(length(FV))]);
    end
    legend(h,'min','neutral','max');
    
end

experimentDirName = 'experiments_results';
mkdir(experimentDirName);

save_figures(fig, experimentDirName, 'ffd', 10, [8 8])