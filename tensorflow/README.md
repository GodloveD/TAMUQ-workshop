# [TensorFlow](https://www.tensorflow.org/)

TensorFlow is an end-to-end open source machine learning platform originally
developed at Google.

TensorFlow is a very challenging program to install from scratch.  This example
will demonstrate one of the chief examples of using containers in HPC. Namely,
the ability to get up and running quickly and easily with a complicated 
program by using an existing container.

## building / pulling the container

The definition file pulls the 1.13.1-gpu version of TensorFlow from Docker Hub.
You can build it like so:

```
$ sudo singularity build tensorflow-1.13.1-gpu.simg docker://tensorflow/tensorflow:1.13.1-gpu
```

You can also accomplish the same thing using the `pull` command like so:

```
$ singularity pull docker://tensorflow/tensorflow:1.13.1-gpu
```

Note that we could omit the `1.13.1-gpu` tag to pull the latest version, but 
this is a poor great practice because it's not very reproducible.  If you did 
the same thing twice in a row you could get two totally different containers. 

## [MNIST](http://yann.lecun.com/exdb/mnist/index.html) training example

Training a model to recognize handwritten digits using the MNIST handwritten 
digit database is like the "hello world" of TensorFlow.  To carry out this 
example, first obtain the TensorFlow `models` repo from GitHub:

```
$ git clone https://github.com/tensorflow/models.git
```

Now you are ready to check your TensorFlow containers using a python script to
start training a model on the MNIST data set.  Note that this script will
download the handwritten digit data if you have not already obtained it.

```
$ singularity exec tensorflow-1.13.1-gpu.simg \
    python models/tutorials/image/mnist/convolutional.py
```
The raad2-gfx has been configured to always run with the option to 
bind the NVIDIA driver into the container.  Otherwise it would be necessary to
pass the `--nv` flag with `exec` command above.

After some initialization (in which you should see some info about the GPU in
use) you will see training epochs begin like so:

```
[snip]
Minibatch loss: 8.334, learning rate: 0.010000
Minibatch error: 85.9%
Validation error: 84.5%
Step 100 (epoch 0.12), 2.7 ms
Minibatch loss: 3.262, learning rate: 0.010000
Minibatch error: 6.2%
Validation error: 8.6%
Step 200 (epoch 0.23), 2.5 ms
Minibatch loss: 3.390, learning rate: 0.010000
Minibatch error: 10.9%
Validation error: 4.5%
Step 300 (epoch 0.35), 2.5 ms
[snip]
```
