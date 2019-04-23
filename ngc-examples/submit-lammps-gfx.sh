#!/bin/bash
#SBATCH -p gpu
#SBATCH --nodes=1
#SBATCH --ntasks=18
#SBATCH --gres=gpu:v100:1
#SBATCH --time=00:05:00
set -e; set -o pipefail

#Load required modules
module load cuda10.0

# Download Lennard Jones example input
wget -c https://lammps.sandia.gov/inputs/in.lj.txt
INPUT="-var x 4 -var y 4 -var z 8 -in /host_pwd/in.lj.txt"

# singularity alias
SIMG="$(pwd)/lammps24Oct2018.simg"
SINGULARITY="singularity run --nv -B ${PWD}:/host_pwd ${SIMG}"

# lmp alias, assumes 1 slurm process per GPU
GPU_COUNT=1
LMP="lmp -k on g ${GPU_COUNT} -sf kk -pk kokkos gpu/direct on neigh full comm device binsize 2.8"

# Launch parallel lmp
srun --mpi=pmi2 ${SINGULARITY} ${LMP} ${INPUT}
