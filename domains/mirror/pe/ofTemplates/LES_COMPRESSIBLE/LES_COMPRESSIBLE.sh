#!/bin/bash
#SBATCH --partition=any          # partition (queue) hpc, any, hpc3
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=64
#SBATCH --mem=120G
#SBATCH --output=slurm.%j.out   
#SBATCH --error=slurm.%j.err   

module load openmpi/gnu
module load mpitools/default
module load gcc/default

source /usr/local/stella/OpenFOAM-v1906/OpenFOAM-v1906/etc/bashrc

echo "Number of tasks: " echo $SLURM_NTASKS

bash allClean.sh

start=`date +%s`

. $WM_PROJECT_DIR/bin/tools/RunFunctions

## generate mesh
runApplication blockMesh
runApplication surfaceFeatureExtract
runApplication decomposePar

runParallel snappyHexMesh 32 -overwrite

meshTime=`date +%s`
echo "$((meshTime-start))" >> mesh.timing

# reconstructParMesh -constant 
# rm -r proc*
# rm log.*

# runApplication decomposePar

## Copy initial conditions
ls -d processor* | xargs -I {} rm -rf ./{}/0
ls -d processor* | xargs -I {} cp -r 0org ./{}/0
cp -r 0org 0

runParallel patchSummary 32 
runParallel rhoPimpleFoam 32 

cfdEnd=`date +%s`
echo "$((cfdEnd-cfdStart))" >> cfd.timing

# runApplication reconstructPar -latestTime

# Return results
cp postProcessing/forceCoeffs/0/coefficient.dat result.dat

end=`date +%s`
echo "$((end-start))" >> all.timing
