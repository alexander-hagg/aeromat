#!/bin/bash
#SBATCH --partition=any
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --mem=120G
#SBATCH --output=slurm.%j.out   
#SBATCH --error=slurm.%j.err    

module load openmpi/gnu
module load mpitools/default
module load gcc/default

# . ~/OpenFOAM/OpenFOAM-v1906/etc/bashrc
of1812

echo "Number of tasks: " echo $SLURM_NTASKS

## Clean
. $WM_PROJECT_DIR/bin/tools/CleanFunctions
cleanCase

start=`date +%s`

. $WM_PROJECT_DIR/bin/tools/RunFunctions

### generate mesh
runApplication blockMesh
runApplication surfaceFeatureExtract
runApplication decomposePar

mpirun -np 32 snappyHexMesh  -parallel  -overwrite

meshTime=`date +%s`
echo "$((meshTime-start))" >> mesh.timing

# reconstructParMesh -constant
# rm -r proc*
# rm log.*

## run RANS  #restore0Dir -processor
runApplication decomposePar

## Copy initial conditions
ls -d processor* | xargs -I {} rm -rf ./{}/0
ls -d processor* | xargs -I {} cp -r 0 ./{}/0

mpirun -np 32 patchSummary
mpirun -np 32 simpleFoam -parallel

cfdEnd=`date +%s`
echo "$((cfdEnd-cfdStart))" >> cfd.timing


runApplication reconstructPar -latestTime
##rm -r processor*

end=`date +%s`
echo "$((end-start))" >> all.timing

# Return results
cp postProcessing/forceCoeffs1/0/forceCoeffs.dat result.dat
cp postProcessing/mirror/0/forces.dat forces.dat
