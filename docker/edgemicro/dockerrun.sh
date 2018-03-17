#!/bin/bash

docker create --name edgemicro -v $PWD/config:/opt/apigee/.edgemicro -v $PWD/logs:/opt/apigee/logs -e EDGEMICRO_ORG=gaccelerate5 -e EDGEMICRO_ENV=test -e EDGEMICRO_KEY=key -e EDGEMICRO_SECRET=secret -e EDGEMICRO_DECORATOR=1 -p 8000:8000 -p 8443:8443 -P -it edgemicro 
docker start $(docker ps -aqf name=edgemicro)
docker ps
echo "Testing the api"
sleep 5
curl http://localhost:8000;echo;
