#!/bin/bash
module load matlab/default

# Create base OpenFOAM cases and launch case runners
nCases=4
export destFolderName=/scratch/$USER/sailCFD/
mkdir $destFolderName

# 32 (real) Cores (1 job per node)
export repositoryFolderName="/home/$USER/aeromat"
export templateFolderName="$repositoryFolderName/domains/mirror/pe/ofTemplates/RANS_INCOMPRESSIBLE"

for (( i=1; i<=$nCases; i++ ))
do
 	caseName=$destFolderName"case$i"
	echo $caseName	
	rm -r $caseName/*
 	cp -TR $templateFolderName $caseName
	export PBS_WORKDIR="$caseName"
	sbatch $caseName/submit.sh
done 

# Launch SAIL
cases=$(($nCases))
echo 'SAIL:MIRROR Main Script'
export NCASES=NCASES
sbatch sb_hpcMirror.sh
