#!/bin/bash

docker build -t edgemicro_apigee_setup .
docker tag edgemicro_apigee_setup:latest edgemicrok8/edgemicro_apigee_setup:latest
docker push edgemicrok8/edgemicro_apigee_setup:latest
