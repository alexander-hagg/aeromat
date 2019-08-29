# aeromat

## Structure of this repository


demo.m - a demo script i
 
Quality Diversity algorithms
./QD
grid - MAP-Elites
sail - QD with Surrogate Assistance

Configuration of MAP-Elites and SAIL
./QD/grid/defaultParamSet.m
./QD/sail/infillParamSet.m

Domain description for 3D mirror domain
./domains/mirror/domain.m

Evaluation:
mirror_OpenFoamResult.m
mirror_PreciseEvaluate.m

RANS incompressible use case
./domains/mirror/pe/ofTemplates/RANS_INC

Experiment scripts
./experiments:
launch_hpcMirror.sh
launch_hpcMirrorFoamTest.sh
runFoamTest.m
sail_Mirror_RANSIncompressible.m
sb_hpcMirror.sh
sb_hpcMirrorFoamTest.sh

## Scans of velomobile
./domains/velomobile:
body.stl
hood.stl
wheelcasings.stl
