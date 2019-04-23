Nvidia GPU cloud container registry provides pre-packaged containeraized applications from different domains i.e. 
Deep Learning, High performance computing etc.
Users can make use of NGC to download prebuilt containers and run them on raad2.
Most of these containers are built for GPU accelerated computing, but they might work for non GPU workloads as well.

We will demonstrate use of NGC on raad2 with Singularity.

### Create NGC account
To download container from NGC, users should have NGC account. You can register for one here; https://ngc.nvidia.com
### Get your API key from NGC
Open this link: https://ngc.nvidia.com/setup and click "Get API Key"
### Setup authentication from raad2 to NGC
Add this information to your raad2 account to allow Singularity to authenticate to your NGC account
```
echo "export SINGULARITY_DOCKER_USERNAME='\$oauthtoken'" >> ~/.bashrc
echo "export SINGULARITY_DOCKER_PASSWORD=<api_key>" >> ~/.bashrc
source ~/.bashrc
```
### Download a container from NGC
```
singularity build lammps24Oct18.simg docker://nvcr.io/hpc/lammps:24Oct2018
```
### Submit batch job file to run your application in container

```
sbatch submit-lammps-gfx.sh
```
