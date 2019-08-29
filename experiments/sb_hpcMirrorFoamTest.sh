#!/bin/bash
#SBATCH --partition=any          # partition (queue)
#SBATCH --nodes=1                # number of nodes
#SBATCH --ntasks-per-node=32     # number of cores per node
#SBATCH --mem=180G               # memory per node in MB (different units with suffix K|M|G|T)
#SBATCH --time=72:00:00          # total runtime of job allocation (format D-HH:MM:SS; first parts optional)
#SBATCH --output=slurm.%j.out    # filename for STDOUT (%N: nodename, %j: job-ID)
#SBATCH --error=slurm.%j.err     # filename for STDERR
#SBATCH --export=ALL
#SBATCH --exclusive

module load matlab/default

# Run experiment
cd $PBS_O_HOME/aeromat/experiments/
matlab -nodisplay -nosplash -nodesktop -r "runFoamTest"
