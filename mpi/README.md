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

In general we can think of packaging MPI application in containers using two configurations:

## Configuration 01
Install OpenMpi/Mpich inside the container and compile your application using these libraries. Port this application on raad2 and inject Intel MPI or Cray MPI inside the container. This will make use of Host MPI libraries.

## Configuration 02
Install complete MPI runtume inside the container. That could be Intel/OpenMpi/Cray MPI runtime. Build your code/application e.g. Lammps, Grommacs, Gaussian against this MPI inside the container. Port this container to raad2. This will not rely on host MPI libraries. 

### Example
Below example demonstrate the ability of dynamically linking MPI libraries on the run time i.e. First Configuration listed above. We have tested it for Intel MPI on raad2. Part of this example is referenced from Taylor Childers from ANL.

Step 1. Build a base centos image and install MPICH.
Step 2. Compile mpi application inside the container using container MPI libraries.
Step 3. Port the container on raad2 and link with host Intel MPI.

### Build a container from definition file (Recipe for the container)

All the steps you want to perform in the container can be listed in a definition file or a recipe. On your local resource, issue following;

```
cd ~/TAMUQ-workshop/mpi
singularity build --writable mpiapp.simg Singularity_mpich33.def
```

Use the batch script "submit-raad2-intel.sh" to submit your job file.

```
sbatch submit-raad2-.sh
```

The output should look like so:

```
```

