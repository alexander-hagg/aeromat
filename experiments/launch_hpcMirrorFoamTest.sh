#!/bin/bash

# Create base OpenFOAM cases and launch case runners
nCases=0

destFolderName="/scratch/$USER/sailCFD/"

# 32 (real) Cores (1 job per node)
baseFolderName=/home/$USER/aeromat/domains/mirror/pe/ofTemplates/hpc1_mirror_only
for (( i=1; i<=$nCases; i++ ))
do
	caseName=$destFolderName"case$i"
	echo $caseName
	cp -TR $baseFolderName $caseName
 	export PBS_WORKDIR="$caseName"
	sbatch $caseName/submit.sh
done 

# Launch SAIL
cases=$(($nCases))
echo 'TEST: SAIL Mirror Main Script'
export NCASES=NCASES
export baseFolderName=baseFolderName
sbatch sb_hpcMirrorFoamTest.sh