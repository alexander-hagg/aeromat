function infill = infillParamSet(varargin)
%SAILPARAMSET infill configuration for surrogate-assistance

infill.nAdditionalSamples = 10;
infill.nAddSamplesPerIteration = 10;
infill.trainingMod        = 3;
infill.featureResolution  = [20 20];
infill.retryInvalid       = true;

end

