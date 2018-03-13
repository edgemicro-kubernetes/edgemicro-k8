#!/bin/bash

docker build -t edgemicro_proxy_init .
docker tag edgemicro_proxy_init:latest edgemicrok8/edgemicro_proxy_init:latest
docker push edgemicrok8/edgemicro_proxy_init:latest
