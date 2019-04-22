# [GATE](http://www.opengatecollaboration.org/home)

GATE is an advanced open source software developed by the international 
OpenGATE collaboration and dedicated to numerical simulations in 
medical imaging and radiotherapy.

GATE is a very difficult application to install on bare metal because it has a 
complicated dependency graph and environment. For this reason, the 
OpenGATE collaboration which manages GATE maintains a 
[Docker container](https://hub.docker.com/r/opengatecollaboration/gate).

However, this container does not work  when ported to Singularity.
This is because, the environment is created in the Docker container by relying on 
automated sourcing of files like `~/.bashrc` at runtime.  It is a
best practice to use the `ENV` keyword to properly add variables to 
the environment. 

Singularity does not source files in the user's `$HOME`
directory at runtime, because, by default, the home directory is bind 
mounted into the container from the host system during startup.  Instead,
files in `/.singularity.d/env` are sourced in alpha-numeric order when a 
container is initiated. When you add variables to the environment using 
the `ENV` keyword in a DockerFile, or the `%post` section in a definition
file, you ensure that they will be place in a file in `/.singularity.d/env`
and appropriately set at runtime.  

## building GATE

Because of the GATE Docker container does not use the `ENV`
keyword to set environment variables, they must be added manually in Singularity using
the `%environment` section in the definition file.  The DockerFile is 
not available on Docker Hub, so one must start the GATE container in 
Docker and then list the environment with the `env` command to see the 
necessary variables. Once the definition file is created, the container can 
be built like so:

```
$ sudo singularity build gate.simg gate.def
```

## running GATE

Once built, GATE can be initiated within the container simply by calling
the container as an executable:

```
$ ./gate.simg
```

Any command line argument supplied to the container will be passed on to the
`Gate` executable within.

```
$ ./gate.simg --help
[Core-0] Gate command line help
[Core-0] Usage: Gate [OPTION]... MACRO_FILE
[Core-0]
[Core-0] Mandatory arguments to long options are mandatory for short options too.
[Core-0]   -h, --help             print the help
[Core-0]   -v, --version          print the version
[Core-0]   -a, --param            set alias. format is '[alias1,value1] [alias2,value2] ...'
[Core-0]   --d                    use the DigiMode
[Core-0]   --qt                   use the Qt visualization mode
```

## Docker to Singularity "gotchas" and best practices

This example illustrates a potential source of frustration when building a
Singularity container from a Docker container.  Though in most cases, Docker
containers can be translated seamlessly to Singularity containers there are 
some potential pitfalls to be aware of.  

In addition to the environment example detailed here, it is important to 
refrain from doing things like installing software into `/root`, expecting
software to run with elevated privileges or as a specific user, assuming a 
writable file system, etc. The most common issues that complicate Docker to 
Singularity translation are detailed in an excellent best practices writup
[here](https://www.sylabs.io/guides/3.1/user-guide/singularity_and_docker.html#best-practices). 

