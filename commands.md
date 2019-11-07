- [Docker](#docker)
  - [docker run](#docker-run)
  - [docker run with -p](#docker-run-with--p)
  - [docker images](#docker-images)
  - [docker pull](#docker-pull)
  - [docker ps](#docker-ps)
  - [docker inspect](#docker-inspect)
  - [docker logs](#docker-logs)
  - [docker rm](#docker-rm)
  - [docker history](#docker-history)
- [Building an image with docker](#building-an-image-with-docker)
  - [docker build](#docker-build)
  - [docker commit](#docker-commit)
  - [docker inspect](#docker-inspect-1)
  - [docker service](#docker-service)
- [Docker Volumes](#docker-volumes)
  - [Create Volume](#create-volume)

# Docker

## docker run
docker run busybox echo "hello world"
- run command against image (busybox) in a container

docker run busybox ls /
- run ls command against root directory for linux container

docker run -i -t busybox
- open an interactive terminal. Terminal remains open, exit with ctrl-c or type exit

docker run -it -d busybox echo "hello world"
- open an interactive terminal. Terminal remains open and is run detached.
- This allows to connect to existing container later to run commands.

docker run -d busybox sleep 1000
- use the -d option to run detached (in background)

docker run --rm busybox sleep 1
- use rm to remove the container after instantiation

docker run --name hello_world busybox
- give a name to a docker container. This can later be referenced in some commands such as network.
***
## docker run with -p
- use the -p option to map a new port number [HOSTPORT:ContainerPort image:tag]
```txt
docker run -it -p 8888:8080 tomcat:8.0
docker run -it -d -p 8888:8080 tomcat:8.0
```
***
## docker images
docker images
- show list of images
- use --digests to see image digests

```txt
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
fiya/debian         1.00                2688e9104e74        9 hours ago         224MB
fiya/debian         latest              8c9ef189e124        9 hours ago         254MB
busybox             latest              020584afccce        2 days ago          1.22MB
debian              jessie              6d90dea6994b        2 weeks ago         129MB
tomcat              8.0                 ef6a7c98d192        13 months ago       356MB
```
***
## docker pull
- docker pull mcr.microsoft.com/windows/servercore:ltsc2019
- docker pull mcr.microsoft.com/windows/servercore:1903
- docker pull mcr.microsoft.com/windows/servercore:1803
- docker pull mcr.microsoft.com/windows/nanoserver@sha256:a87e3729ccbc77da53771e9849553bb18f45178036feb3b5d3a62cc35858f052
***
## docker ps
docker ps
- list runing containers

docker ps -a
- list all containers
***
## docker inspect 
<https://docs.docker.com/engine/reference/commandline/inspect/>
- list low level information about a container or image
- can use name or containerid
```txt
docker inspect 30b75174c819fb83bd285a7604a9af8bdd0b09c8c8cf7885526b4545f24b78ff
docker inspect hello_World
```
***
## docker logs
<https://docs.docker.com/engine/reference/commandline/logs/>
- show logs of a container
- can use name or containerid
***
## docker rm
<https://docs.docker.com/engine/reference/commandline/rm/>
- Remove a container
- works with name or containerid
***
## docker history
<https://docs.docker.com/engine/reference/commandline/history/>
- shows history of an image
- imagename:tag
***
# Building an image with docker
## docker build
<https://docs.docker.com/engine/reference/commandline/build/>
- syntax starts with the FROM keyword
- keep keywords capitalized for readability though not a requirement
- commands are entered into a dockerfile
```txt
FROM debian:jessie
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y vim
```
docker build -t fiya/debian:1.00 .
- builds image from debian
- stores it in the fiya registry locally
- tags with 1.00
- runs dockerfile that exists in current directory
***
## docker commit
<https://docs.docker.com/engine/reference/commandline/commit/>
- create an image from changes to a container
```
docker run -it debian:jessie
apt-get install -y git
exit
docker ps
docker commit e44e185ea04b fiya/debian:1.00
docker images
docker history fiya/debian:1.00
```
- run jessie tag from debian image in an interactive container
- install git ackowledging any prompts
- exit to console
- list running containers
- commit container id to fiya/debian repository with a tag of 1.00
- list images to show commit
- list history of commited image
***
## docker inspect
- tbd
## docker service
- tbd
# Docker Volumes
## Create Volume
<https://docs.docker.com/storage/volumes/>
- create volumes to manage persistent data between containers
```
docker volume create vol1
docker volume ls
docker volume inspect vol1
docker volume rm vol1
```
- create a docker volume
- list docker volumes
- inspect the volume
- remove the volume
```
docker run -d -it `
--name voltest `
--mount source=voltest1,target=C:\app `
<image to run>
```
- running an image and specifing --mount will create the volume if it does not exist
- target directory must already exist in the container
- volume is default read/write
  ```
  docker run -d \
  --name devtest \
  -v myvol2:/app \
  nginx:latest
  ```
  - volumes can also be created with -v instead of --mount with a different syntax









