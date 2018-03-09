#!/bin/bash

docker build -t microgateway .
docker tag microgateway:latest edgemicrok8/microgateway:latest
docker push edgemicrok8/microgateway:latest
