#!/bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]; then 
	echo "Please provide edgemicro version"
        exit 1
fi

version=$1
project_id=$2

docker build -t edgemicro:$version $DIR
docker tag edgemicro:$version edgemicro/edgemicro:$version

if [ $# -eq 1 ]; then
  docker tag edgemicro:$version edgemicro/edgemicro:$version
  docker push edgemicro:$version
fi

if [ $# -eq 2 ]; then
  docker tag edgemicro:$version gcr.io/$project_id/edgemicro:$version
  docker push gcr.io/$project_id/edgemicro:$version
fi
