#!/bin/bash
#!/bin/bash
#SBATCH -J demo
#SBATCH -p ll
#SBATCH --qos=l_long
#SBATCH --time=01:00:00
#SBATCH -N 2
#SBATCH --ntasks=48
#SBATCH --hint=nomultithread

CONTAINER="mpiapp.simg"

module unuse /lustre/sw/xc40ac/modulefiles
module switch PrgEnv-cray PrgEnv-intel

export SINGULARITYENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

RANKS_PER_NODE=24

srun --mpi=pmi2 -n 48 singularity run -B /opt:/opt:ro $CONTAINER
