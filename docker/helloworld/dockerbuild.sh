#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -ne 1 ]; then 
	echo "Please Provide Verson Number to build"
fi

version=$1
docker build -t helloworld:$version $DIR
docker tag helloworld:$version edgemicrok8/helloworld:$version
docker push edgemicrok8/helloworld:$version
