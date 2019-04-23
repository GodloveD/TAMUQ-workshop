# MPI jobs

Message Passing Interface (MPI) allows applications to run across 
multiple nodes as if they were all part of a single system.

Singularity employs a "hybrid" MPI model, allowing you to run MPI
jobs more easily. The basic idea is that Singularity expects MPI
to be present both inside and outside of the container.  When 
you execute a container with MPI code, you will call `mpiexec`
or a similar launcher on the `singularity`
command itself. The MPI process outside of the container will 
then work in tandem with MPI inside the container and the 
containerized MPI code to instantiate the job.  

For now, we have tested Singularity on raad2 mostly with Intel MPI. 
Since Intel MPI is licensed, it is probably easier to bind mount
it into the container at runtime rather than to build a container in
which it is pre-installed.

As a general rule, the more highly optimized software is, the less 
portable it is. This rule applies just as well
to MPI. Less optimized implementations such as OpenMPI tend to be 
more portable, while highly optimized implementations such as 
Intel are less portable. 

An MPI application can be packaged in a container in multiple ways. 
The example we share here demonstrates the first approach, but the
second approach is technically possible and is mentioned just for
the sake of completeness.

First Approach 

Install OpenMPI or MPICH inside your container and compile your 
application using that library. Then, copy your container to raad2
and bind mount the directory for either the Intel MPI library inside 
the container.  Set the container environment variables such that 
the application links to the library mounted from the outside.

Second Approach

Install the complete MPI runtime inside the container. This could be 
Intel, OpenMPI, or MPICH. Build your application (e.g. Lammps, Grommacs,
OpenFOAM, etc.) against this "internal" MPI.  Copy this container to 
raad2.  Technically this containers could run without relying on the 
host MPI libararies, although on raad2 that would require some system 
re-configuration that is  currently being studied.

### Example

The example below demonstrates the first approach. We have tested it 
using Intel MPI on raad2.  Part of this example is referenced from 
Taylor Childers from ANL.

Step 1. Build a base centos image and install MPICH. <br>
Step 2. Compile the MPI application inside the container using the container MPI library (i.e. MPICH). <br>
Step 3. Copy the container to raad2 and configure the environment to link with host Intel MPI. <br>

All the steps you want to perform in the container can be listed in a definition file or a recipe.

On your local resource where you have sudo access, issue following;

```
cd ~/TAMUQ-workshop/mpi
singularity build --writable mpiapp.simg Singularity_mpich33.def
```

Copy the container and submission script to raad2
```
scp mpiapp.simg username@raad2a.qatar.tamu.edu:~/
scp submit-raad2-intel.sh username@raad2a.qatar.tamu.edu:~/
```

Login to raad2 and sse the batch script "submit-raad2-intel.sh" to submit your job file.

```
user@raad2a:~> sbatch submit-raad2-intel.sh
Submitted batch job <jid>

```

Inspect the output and it should look like below;

```
user@raad2a:~> more slurm-jid.out

worker nid00022 1 of 48
worker nid00022 5 of 48
worker nid00239 24 of 48
worker nid00022 12 of 48
worker nid00239 28 of 48
worker nid00022 13 of 48
.
.
.
pi is approximately 3.1417259869152536, Error is 0.0001333333254605

###Listing Dynamic Dependencies###
        linux-vdso.so.1 =>  (0x00002aaaaaad0000)
        libmpi.so.12 => /opt/intel/compilers_and_libraries_2017.1.132/linux/mpi/intel64/lib/libmpi.so.12 (0x00002aaaaaccf000)
        libc.so.6 => /lib64/libc.so.6 (0x00002aaaab9e6000)
        librt.so.1 => /lib64/librt.so.1 (0x00002aaaabdb3000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00002aaaabfbb000)
        libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00002aaaac1bf000)
        /lib64/ld-linux-x86-64.so.2 (0x00002aaaaaaab000)
        libpthread.so.0 => /lib64/libpthread.so.0 (0x00002aaaac3d5000)
.
.
.
```
This job ran on 02 nodes nid00022 and nid00239 and computed value of pi. At the end it listed the dynamic depencies of the executable to verify that its linking to host Intel MPI.




