#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -ne 1 ]; then 
	echo "Please Provide Verson Number to build"
fi

version=$1

docker build -t edgemicro_apigee_setup:$version $DIR
docker tag edgemicro_apigee_setup:$version edgemicrok8/edgemicro_apigee_setup:$version
docker push edgemicrok8/edgemicro_apigee_setup:$version
