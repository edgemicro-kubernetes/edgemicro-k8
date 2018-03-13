#!/bin/bash

docker create --name microgateway -v $PWD/config:/opt/apigee/.edgemicro -v $PWD/logs:/opt/apigee/logs -e EDGEMICRO_ORG=gaccelerate5 -e EDGEMICRO_ENV=test -e EDGEMICRO_KEY=key -e EDGEMICRO_SECRET=secret -p 8000:8000 -p 8443:8443 -P -it microgateway 
docker start $(docker ps -aqf name=microgateway)
docker ps
echo "Testing the api"
sleep 5
curl http://localhost:8000;echo;
