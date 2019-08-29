#!/bin/bash
of1812
module load matlab/default

# Create base OpenFOAM cases and launch case runners
nCases=0
mkdir /tmp/$USER
destFolderName="/tmp/$USER/sailCFD/"
mkdir $destFolderName

# 32 (real) Cores (1 job per node)
repositoryFolderName=/home/$USER/aeromat
templateFolderName=$repositoryFolderName/domains/mirror/pe/ofTemplates/RANS_INC
for (( i=1; i<=$nCases; i++ ))
do
	caseName=$destFolderName"case$i"
	echo $caseName
	cp -TR $templateFolderName $caseName
 	export PBS_WORKDIR="$caseName"
	sbatch $caseName/submit.sh
done 

# Launch SAIL
cases=$(($nCases))
echo 'TEST:SAIL:MIRROR Main Script'
export NCASES=NCASES
sbatch sb_hpcMirrorFoamTest.sh
