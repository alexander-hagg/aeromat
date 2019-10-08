#!/bin/bash
source /usr/local/stella/OpenFOAM1812/OpenFOAM-v1812/etc/bashrc WM_NCOMPPROCS=32
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
	cp -TR $templateFolderName $caseName
	rm $caseName/*.signal
 	export PBS_WORKDIR="$caseName"
	sbatch $caseName/submit.sh
done 

# Launch SAIL
cases=$(($nCases))
echo 'SAIL:MIRROR Main Script'
export NCASES=NCASES
sbatch sb_hpcMirror.sh
