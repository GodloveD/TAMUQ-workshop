# MPI jobs

Message Passing Interface (MPI) allows applications to run across 
multiple CPUs (perhaps even across multiple nodes) as if they 
were all part of one single system.

Singularity employs a "hybrid" MPI model allowing you to run MPI
jobs more easily. The basic idea is that Singularity expects MPI
to be present both inside and outside of the container.  When 
you execute an container with MPI code, you will call `mpiexec`
or a similar command outside of Singularity on the `singularity`
command itself. The MPI process outside of the container will 
then work in tandem with MPI inside the container and the 
containerized MPI code to instantiate the job.  

Currently, Singularity on raad2 only supports Intel MPI and 
will only run on multiple CPUs within a single node. Since 
Intel MPI is licensed, it is probably easier to bind mount
it into the container at runtime rather than build a container in
which it is pre-installed. As a general rule, the more highly 
optimized software is, the less portable. This rule extends well
to MPI. Less optimized implementations such as OpenMPI tend to be 
more portable, while highly optimized implementations such as 
Intel are less portable. 

## building an MPI application 

This example will use the (MPI Hello World)[http://mpitutorial.com/tutorials/mpi-hello-world/] 
tutorial by Wes Kendall. 

On raad2, first clone the git repo:

```
$ git clone https://github.com/wesleykendall/mpitutorial
```

Then set the environment up to use the Intel MPI compiler:

```
$ module unuse /lustre/sw/xc40ac/modulefiles
$ module unload PrgEnv-cray
$ module load PrgEnv-intel
``` 

Now we are ready to compile the MPI Hello World example:

```
$ cd mpitutorial/tutorials/mpi-hello-world/code
$ export MPICC=`which mpiicc`
$ make
$ cp mpi_hello_world ~/
$ cd ~
```

## run the job from within a container

First you need to obtain a container. In many cases, you would 
build a container with MPI inside of it and then compile the app
within the container itself. But for this example we will actually
be using Intel MPI from the host system through a bind mount, so
we can just grab a vanilla CentOS container. 

```
$ singularity pull docker://centos
```

Then create a batch script:

```sh
#!/bin/bash
#SBATCH -J mpi_tester
#SBATCH -p express
#SBATCH --qos ex
#SBATCH --time=00:05:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=24
#SBATCH --hint=nomultithread

module unuse /lustre/sw/xc40ac/modulefiles
module unload PrgEnv-cray
module load PrgEnv-intel

export MPIEXEC=/opt/intel/compilers_and_libraries_2017.1.132/linux/mpi/intel64/bin/mpiexec.hydra
export SINGULARITY_BINDPATH=/opt/intel

$MPIEXEC -n 24 singularity exec ~/centos.simg ~/mpi_hello_world
```

Save the batch file with the name `sing.job`.  Then submit the job
with `sbatch`. 

```
$ sbatch sing.job
```

The output should look like so:

```
dagodlo21@raad2a:~> cat slurm-4394607.out
Hello world from processor nid00012, rank 2 out of 24 processors
Hello world from processor nid00012, rank 3 out of 24 processors
Hello world from processor nid00012, rank 6 out of 24 processors
Hello world from processor nid00012, rank 11 out of 24 processors
Hello world from processor nid00012, rank 12 out of 24 processors
Hello world from processor nid00012, rank 14 out of 24 processors
Hello world from processor nid00012, rank 15 out of 24 processors
Hello world from processor nid00012, rank 17 out of 24 processors
Hello world from processor nid00012, rank 21 out of 24 processors
Hello world from processor nid00012, rank 0 out of 24 processors
Hello world from processor nid00012, rank 1 out of 24 processors
Hello world from processor nid00012, rank 4 out of 24 processors
Hello world from processor nid00012, rank 5 out of 24 processors
Hello world from processor nid00012, rank 7 out of 24 processors
Hello world from processor nid00012, rank 8 out of 24 processors
Hello world from processor nid00012, rank 9 out of 24 processors
Hello world from processor nid00012, rank 10 out of 24 processors
Hello world from processor nid00012, rank 13 out of 24 processors
Hello world from processor nid00012, rank 16 out of 24 processors
Hello world from processor nid00012, rank 18 out of 24 processors
Hello world from processor nid00012, rank 19 out of 24 processors
Hello world from processor nid00012, rank 20 out of 24 processors
Hello world from processor nid00012, rank 22 out of 24 processors
Hello world from processor nid00012, rank 23 out of 24 processors
```
