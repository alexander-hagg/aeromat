load('RANS_INCOMPRESSIBLE_3.mat');

%map.fitness = exp(-map.fitness);
map.fitness = -map.fitness;
[~,~,bar] = viewMap(map,d);
fig(1) = gcf;
bar.Label.String = 'log(cD)';
save_figures(fig, experimentDirName, 'map', 16, [6 6])



