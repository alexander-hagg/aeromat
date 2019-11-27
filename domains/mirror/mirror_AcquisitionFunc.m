function [fitness,predValue] = mirror_AcquisitionFunc(samples, drag, varCoef)
%mirror_AcquisitionFunc - Infill criteria based on uncertainty and fitness
%
% Syntax:  [fitness, predValue] = mirror_AcquisitionFunc(samples, drag,d)
%
% Inputs:
%   drag -    [2XN]    - drag coefficient mean and variance
%   d    -             - domain struct 
%   .varCoef  [1X1]    - uncertainty weighting for UCB
%
% Outputs:
%    fitness   - [1XN] - Fitness value (higher is better)
%    predValue - [1XN] - Predicted drag coefficient (mean)
%

% Author: Alexander Hagg, Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (HBRS)
% email: alexander.hagg@h-brs.de, adam.gaier@h-brs.de
% Jun 2016; Last revision: 27-Nov-2019

%------------- BEGIN CODE --------------

fitness = (drag(:,1) + (drag(:,2)*varCoef)); % better fitness is higher fitness  
predValue{1} = drag(:,1);
predValue{2} = drag(:,2);

%------------- END OF CODE --------------
