- [Docker Security](#docker-security)
  - [pulling with tags vs digest](#pulling-with-tags-vs-digest)
- [DCT](#dct)
# Docker Security
## pulling with tags vs digest
```
docker pull alpine:edge
docker pull alpine@sha256:e5ab6f0941eb01c41595d35856f16215021a941e9893501d632ed4c0ee4e53a6
```
- pulling with tags is easier and more readable but not unique, tags are mutable and multiple images can have the same tags\
- pulling with a digest guarantees the image you are attempting to pull is the correct image
  
# DCT
- Docker Content Trust is a system designed to handle name resolution from Image tags to Image digests
```
export DOCKER_CONTENT_TRUST=1
set DOCKER_CONTENT_TRUST=1
$env:DOCKER_CONTENT_TRUST = "1"