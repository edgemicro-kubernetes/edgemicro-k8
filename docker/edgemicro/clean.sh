docker stop $(docker ps -aqf name=microgateway)
docker rm $(docker ps -aqf name=microgateway)
rm -fr config/*-cache-*.yaml
