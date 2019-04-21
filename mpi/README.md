# MPI jobs

Message Passing Interface (MPI) allows applications to run across 
multiple CPUs (perhaps even across multiple nodes) as if they 
were all part of one single system.

Singularity employs a "hybrid" MPI model allowing you to run MPI
jobs more easily. The basic idea is that Singularity expects MPI
to be present both inside and outside of the container.  When 
you execute a container with MPI code, you will call `mpiexec`
or a similar binary on the `singularity`
command itself. The MPI process outside of the container will 
then work in tandem with MPI inside the container and the 
containerized MPI code to instantiate the job.  

Currently, Singularity on raad2 only supports Intel MPI. Since 
Intel MPI is licensed, it is probably easier to bind mount
it into the container at runtime rather than build a container in
which it is pre-installed. 

As a general rule, the more highly 
optimized software is, the less portable. This rule extends well
to MPI. Less optimized implementations such as OpenMPI tend to be 
more portable, while highly optimized implementations such as 
Intel are less portable. 

## building an MPI application 

This example will use the [MPI Hello World](http://mpitutorial.com/tutorials/mpi-hello-world/)
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
#SBATCH -N 2
#SBATCH --ntasks-per-node=24
#SBATCH --hint=nomultithread

module unuse /lustre/sw/xc40ac/modulefiles
module unload PrgEnv-cray
module load PrgEnv-intel

export SINGULARITY_BINDPATH=/opt/intel

srun -n 48 --mpi=pmi2 singularity exec  ~/centos.simg ~/mpi_hello_world
```

Save the batch file with the name `sing.job`.  Then submit the job
with `sbatch`. 

```
$ sbatch sing.job
```

The output should look like so:

```
dagodlo21@raad2b:~> cat slurm-4561569.out
Hello world from processor nid00008, rank 1 out of 48 processors
Hello world from processor nid00012, rank 25 out of 48 processors
Hello world from processor nid00008, rank 7 out of 48 processors
Hello world from processor nid00008, rank 13 out of 48 processors
Hello world from processor nid00008, rank 18 out of 48 processors
Hello world from processor nid00008, rank 19 out of 48 processors
Hello world from processor nid00008, rank 21 out of 48 processors
Hello world from processor nid00008, rank 0 out of 48 processors
Hello world from processor nid00008, rank 2 out of 48 processors
Hello world from processor nid00008, rank 3 out of 48 processors
Hello world from processor nid00008, rank 4 out of 48 processors
Hello world from processor nid00008, rank 5 out of 48 processors
Hello world from processor nid00008, rank 6 out of 48 processors
Hello world from processor nid00008, rank 8 out of 48 processors
Hello world from processor nid00008, rank 9 out of 48 processors
Hello world from processor nid00008, rank 10 out of 48 processors
Hello world from processor nid00008, rank 11 out of 48 processors
Hello world from processor nid00008, rank 12 out of 48 processors
Hello world from processor nid00008, rank 14 out of 48 processors
Hello world from processor nid00008, rank 15 out of 48 processors
Hello world from processor nid00008, rank 16 out of 48 processors
Hello world from processor nid00008, rank 17 out of 48 processors
Hello world from processor nid00008, rank 20 out of 48 processors
Hello world from processor nid00008, rank 22 out of 48 processors
Hello world from processor nid00008, rank 23 out of 48 processors
Hello world from processor nid00012, rank 30 out of 48 processors
Hello world from processor nid00012, rank 46 out of 48 processors
Hello world from processor nid00012, rank 47 out of 48 processors
Hello world from processor nid00012, rank 24 out of 48 processors
Hello world from processor nid00012, rank 26 out of 48 processors
Hello world from processor nid00012, rank 27 out of 48 processors
Hello world from processor nid00012, rank 28 out of 48 processors
Hello world from processor nid00012, rank 29 out of 48 processors
Hello world from processor nid00012, rank 31 out of 48 processors
Hello world from processor nid00012, rank 32 out of 48 processors
Hello world from processor nid00012, rank 33 out of 48 processors
Hello world from processor nid00012, rank 34 out of 48 processors
Hello world from processor nid00012, rank 35 out of 48 processors
Hello world from processor nid00012, rank 36 out of 48 processors
Hello world from processor nid00012, rank 37 out of 48 processors
Hello world from processor nid00012, rank 39 out of 48 processors
Hello world from processor nid00012, rank 41 out of 48 processors
Hello world from processor nid00012, rank 42 out of 48 processors
Hello world from processor nid00012, rank 43 out of 48 processors
Hello world from processor nid00012, rank 44 out of 48 processors
Hello world from processor nid00012, rank 45 out of 48 processors
Hello world from processor nid00012, rank 38 out of 48 processors
Hello world from processor nid00012, rank 40 out of 48 processors
```

Please note that this is just a demo is not really intended to be a useful example.
In this demo, an application was built on the host system, and then it was run 
inside of a container by bind mounting the Intel MPI directory into the container.
You may (rightly) wonder what is the point of the container in this example,
since you could easily run the hello world application without using a container
at all.  

In most real-world situations, both the MPI implementation and the compiled
application would actually be installed into the container. But this was not 
possible for the demo since Intel MPI is licensed and care must be taken not to
distribute it. Hopefully, the demo still illustrates the basic ideas behind
running a containerized MPI application.  
