- [About RUN](#about-run)
  - [chaining run instructions](#chaining-run-instructions)
- [About CMD](#about-cmd)
  - [what it does](#what-it-does)
- [About docker cache](#about-docker-cache)
  - [how it works](#how-it-works)
  - [Aggressive Caching (if caching not used properly)](#aggressive-caching-if-caching-not-used-properly)
  - [First solution to Aggressive caching](#first-solution-to-aggressive-caching)
  - [Second solution to Aggressive caching](#second-solution-to-aggressive-caching)
- [About copy](#about-copy)
  - [how it works](#how-it-works-1)
  - [on windows](#on-windows)
- [About ADD](#about-add)
  - [how it works](#how-it-works-2)
  - [on windows](#on-windows-1)
***
# About RUN
## chaining run instructions
- each RUN executes on the topmost writable layer of the container
  - then commits as new image
- each RUN instruction creates new image layer that is used for each subsequent step
- recommendation to chain RUN instructions to reduce # of image layers
- When chaining, use \ or in windows container, use ` or \
    ```txt
    FROM debian:jessie
    RUN apt-get update && apt-get install -y \
        git \
        vim
    ```
- docker built -t fiya/debian:1.01 .
  - save to fiya repository with a tag of 1.01. Use dockerfile in current directory
- docker images
    ```txt
    PS C:\Users\fiyab\Documents\docker> docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
    fiya/debian         1.01                3db5da0dbba0        About a minute ago   253MB
    fiya/debian         1.00                2688e9104e74        12 hours ago         224MB
    fiya/debian         latest              8c9ef189e124        12 hours ago         254MB
    busybox             latest              020584afccce        2 days ago           1.22MB
    debian              jessie              6d90dea6994b        2 weeks ago          129MB
    tomcat              8.0                 ef6a7c98d192        13 months ago        356MB
    ```
- docker history - notice the reduced number of images
    ```txt
    PS C:\Users\fiyab\Documents\docker> docker history 3db5da0dbba0
    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    3db5da0dbba0        3 minutes ago       /bin/sh -c apt-get update && apt-get install…   124MB
    6d90dea6994b        2 weeks ago         /bin/sh -c #(nop)  CMD ["bash"]                 0B
    <missing>           2 weeks ago         /bin/sh -c #(nop) ADD file:a1b099a3419f20411…   129MB
    ```
***
# About CMD
## what it does
- specifies instruction to execute when container starts, not when building image
- if CMD not specified, default command from base image is used. For linux, it's bash. Not sure about windows, maybe cmd
- CMD can be overwritten at container instantiation (docker run)
- CMD can be specified in exec form (preferred) or shell form
- e.g. using dockerfile below
    ```txt
    FROM debian:jessie
    RUN apt-get update && apt-get install -y \
        git \
        vim
    CMD ["echo","hello world"]
    ```
- build. Notice the Using cache in step 2. Docker reused cache since Step 1 and Step 2 already exist in the images layer.
    ```txt
    PS C:\Users\fiyab\Documents\docker> docker build -t fiya/debian:1.01 .
    Sending build context to Docker daemon  2.048kB
    Step 1/3 : FROM debian:jessie
    ---> 6d90dea6994b
    Step 2/3 : RUN apt-get update && apt-get install -y     git     vim
    ---> Using cache
    ---> 3db5da0dbba0
    Step 3/3 : CMD ["echo","hello world"]
    ---> Running in b34dafc3e529
    Removing intermediate container b34dafc3e529
    ---> 0492afe5337d
    Successfully built 0492afe5337d
    Successfully tagged fiya/debian:1.01    
    ```
- Execute the image build from the previous step
  - Notice hello world output
  - Notice behavior of overriding the echo at runtime
    ```txt
    PS C:\Users\fiyab\Documents\docker> docker run 0492afe5337d
    hello world
    PS C:\Users\fiyab\Documents\docker> docker run 0492afe5337d echo "rahrah"
    rahrah
    ```
***
# About docker cache
## how it works
- Since each instruction builds a new image layer
  - subsequent runs reuse the existing image layer if instructions are not changed
- Reduces build time if building many containers

## Aggressive Caching (if caching not used properly)
- Can cause out-of-sync applications if not used properly
- consider the dockerfile below.
  - on image layer, apt-get updates applications
  - on second image layer, git is installed
  - All layers in docker cache after build
    ```txt
    FROM ubuntu:14.04
    RUN apt-get update
    RUN apt-get install -y git
    ```
- dockerfile is then modified
  - first two lines are cached and reused so they are not rerun
  - can potentially get out-of-date applications for git and curl
    ```txt
    FROM ubuntu:14.04 <---- cached
    RUN apt-get update <---- cached
    RUN apt-get install -y git curl
    ```
## First solution to Aggressive caching
- chain instructions
    ```txt
    FROM ubuntu:14.04
    RUN apt-get update && apt-get install -y \
        git \
        curl
    ```
- whenever apt-get is modified, whole instruction is rerun since there is a change
## Second solution to Aggressive caching
- use the --no-cache=true during docker build command:
  `docker build -t fiya/debian . --no-cache=true`
***
# About copy
## how it works
- copies files and directories to the container's file system
- must be in a path relative to dockerfile
- copy source destination
- e.g. create file
    ```txt
    PS C:\Users\fiyab\Documents\docker> new-item myfile.txt


        Directory: C:\Users\fiyab\Documents\docker


    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    -a----        11/2/2019  12:48 PM              0 myfile.txt
    ```
- edit dockerfile
    ```txt
    FROM debian:jessie
    RUN apt-get update && apt-get install -y \
        git \
        vim
    COPY myfile.txt /src/myfile.txt    
    ```
- docker build to rebuild image
    ```txt
    PS C:\Users\fiyab\Documents\docker> docker build -t fiya/debian:1.01 .
    Sending build context to Docker daemon   2.56kB
    Step 1/3 : FROM debian:jessie
    ---> 6d90dea6994b
    Step 2/3 : RUN apt-get update && apt-get install -y     git     vim
    ---> Using cache
    ---> 3db5da0dbba0
    Step 3/3 : COPY myfile.txt /src/myfile.txt
    ---> 111f84dfdd20
    Successfully built 111f84dfdd20
    Successfully tagged fiya/debian:1.01    
    ```
- docker run to launch container. Navigate to the src directory to see the new file.
    ```txt
    docker run -it 111f84dfdd20   
    root@5b7a67abb23a:/# ls src
    myfile.txt 
    ```        
***
## on windows
<https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/manage-windows-dockerfile>
- same rules apply on windows as the ADD section below
***
# About ADD
## how it works
- very similar to copy command
- allows downloading of files from url and copy to the container
- can also unpack compressed files **(ONLY IN LINUX)**
- COPY is preferred because of transparency.
  - COPY is a stripped down version of ADD
  - use COPY always unless there is a necessity for ADD
## on windows
<https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/manage-windows-dockerfile>
- expansion of compressed files is not supported
- if either source or destination contain white space
  - enclose in [] and "": `ADD ["<source>", "<destination>"]`
- destination format must use / instead of \
  - `ADD test1.txt /temp/` or `ADD test1.txt c:/temp/`