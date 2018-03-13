#!/bin/bash

docker build -t edgemicro .
docker tag edgemicro:latest edgemicrok8/edgemicro:latest
docker push edgemicrok8/edgemicro:latest
