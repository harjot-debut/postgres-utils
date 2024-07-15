#!/bin/bash


# s
./create-uploads-dir.sh

docker pull hs60/docker-test1:latest 

docker pull hs60/docker-test2:latest 

docker-compose -f docker-compose.yaml up -d