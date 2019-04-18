# [Jupyter Notebook](https://jupyter.org/)

The Jupyter Notebook is an open-source web application that allows you to 
create and share documents that contain live code, equations, visualizations 
and narrative text. 

This example with demonstrate one way to host a web server on a compute node
withing a HPC cluster, and will also illustrate a simple runscript example.

## building the container 

Once you've obtained the def file from this repo, you can build it simply like
so:

```
$ sudo singularity build jupyter.simg jupyter.def
```

## hosting a jupyter notebook server

After you've built the container and copied it to raad2-gfx, you are ready to 
start a server. First obtain an interactive session on a compute node:

```
$ sinteractive
```

jupyter notebook writes data to a directory called `/run/user`, but this is
impossible within an immutable Singularity container. To accommodate this
behavior, it is necessary to bind mount a directory into the container. 

First, we'll create the directory:

```
$ mkdir ~/run
```

Next we'll set an environment variable to automatically bind the directory into
the container at the appropriate location:

```
$ export SINGULARITY_BINDPATH=~/run:/run
```

Finally, we'll start the server by calling the Singularity container as an
executable. The runscript (see the definition file) will take care of the rest.

```
$ ./jupyter.simg
```

## connecting to the notebook server on a compute node

Once we've started the server we must be able to connect to it. This can be 
accomplished by setting up a series of ssh tunnels.

First we'll set a tunnel from the login node to the compute node. In a new
terminal window connect to the raad2-gtx login server and issue the following
command:

```
$ ssh -L 8888:localhost:8888 gfx1
```

Be sure to change `gfx1` to another hostname if you acquired another host.

Leave this window open. Then open yet another terminal window and create a 
tunnel from your local machine to the raad2-gtx login node:

```
$ ssh -L 8888:localhost:8888 dagodlo21@raad2-gtx.qatar.tamu.edu
```

Replace `dgodlo21` with your username 

Now you are ready to open a web browser and point it to `localhost:8888`. You
should see a jupyter notebook session running from your compute node. You will
likely need to enter the token from the running server into your web browser.
