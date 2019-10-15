#!/bin/bash
module load matlab/default

# Create base OpenFOAM cases and launch case runners
NCASES=10
export JOBLOCATION="/scratch/$USER/sailCFD/"
mkdir $JOBLOCATION

# 32 (real) Cores (1 job per node)
export REPOSITORYLOCATION="/home/$USER/aeromat"
export CFDSOLVER="RANS_INCOMPRESSIBLE"
export template="$REPOSITORYLOCATION/domains/mirror/pe/ofTemplates/$CFDSOLVER"

for (( i=1; i<=$NCASES; i++ ))
do
	export caseName=$JOBLOCATION"case$i"
	echo $caseName
    rm -r $caseName/*
	cp -TR $template $caseName
	sbatch $caseName/submit.sh
done 

# Launch SAIL
cases=$(($NCASES))
echo 'SAIL:MIRROR Main Script'
sbatch sb_hpcMirror.sh
