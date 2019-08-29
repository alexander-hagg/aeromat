#!/bin/bash
of1812
module load matlab/default

# Create base OpenFOAM cases and launch case runners
nCases=10
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
echo 'SAIL Main Script'
export nCases=nCases
export baseFolderName=baseFolderName
sbatch sb_hpcMirror.sh
