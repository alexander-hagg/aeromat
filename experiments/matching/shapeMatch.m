function [params,phenotype,error] = shapeMatch(expressMethod,nParam,target,d)
%shapeMatch - Matches a parameterized shape to a set of x,y coordinates
%Optional file header info (to give more details about the function than in the H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%Optional file header info (to give more details about the function than in the H1 line)
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
% Inputs:
%    input1 - Description
%    input2 - Description
%    input3 - Description
%
% Outputs:
%    output1 - Description
%    output2 - Description
%
% Example: 
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: adam.gaier@h-brs.de
% May 2016; Last revision: 12-May-2016

%------------- BEGIN CODE --------------

%% CMA-ES options

opts = cmaes;
opts.Restarts = 0;
opts.LBounds = d.ranges(1);
opts.UBounds = d.ranges(2);
opts.StopFitness = 1e-3;
opts.PopSize = 12;
opts.SaveVariables = 'off';
opts.TolFun = 1e-10;
opts.LogTime = 0;
opts.DispModulo = Inf;
opts.MaxFunEvals = 10000;
%initPoint = rand(1,nParam)./range(d.ranges)+d.ranges(1);
initPoint = 0.5*ones(1,nParam);

tic
[~,error,~,~,~,best] = cmaes('matchFit',initPoint,0.3,opts,expressMethod,target,d);
toc
params = best.x';


%%
phenotype = feval(expressMethod,params,'mirrorBase.stl');

 figure(1);
 scatter3(phenotype.vertices(1,:),phenotype.vertices(2,:),phenotype.vertices(3,:))
 view(0,90)
 %view(0,180)
 title('Approximation');
 axis([-80 60 -150 150 600 800]);
 figure(2);
 scatter3(target(:,1),target(:,2),target(:,3))
 title('Target Shape');
 view(0,90)
 axis([-80 60 -150 150 600 800]);
 %view(0,180)
drawnow;
%------------- END OF CODE --------------