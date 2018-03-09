#!/bin/bash

org=gaccelerate5
env=test
key=a4ae2355090c0ab73cf7b813b4e3a19dce576c84ac0a5945c4866f2b79aec729
secret=a053d2a0d84928d8e3c5997616898f992a70cc5bee29f82f117de295bd2db8d3
PROJECT_ID="edge-apigee"

docker build --build-arg ORG="$org" --build-arg ENV="$env" --build-arg KEY="$key" --build-arg SECRET="$secret" -t microgateway .
docker tag microgateway:latest gcr.io/$PROJECT_ID/microgateway:latest
gcloud docker -- push gcr.io/$PROJECT_ID/microgateway:latest
