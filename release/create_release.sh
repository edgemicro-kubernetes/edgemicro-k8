#!/bin/bash


red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`
reset=`tput sgr0`

edgemicroctlDist='https://raw.githubusercontent.com/srinandan/edgemicroctl/master/dist'
ORG=edgemicro-kubernetes
REPO=edgemicro-k8
REQUEST_FILE="$(mktemp /tmp/github.request.XXXX)"
RESPONSE_FILE="$(mktemp /tmp/github.response.XXXX)"

## Command to build and release edgemicro-k8

usage() {

  echo "${blue}Usage: $0 [option...]" >&2
  echo
  echo "   -v, --build-version        * Build Version. "
  echo "   -d, -- build-docker        * Build Docker? y/n. "
  echo "   -k, --git-key              * Git Key. "
  echo "   -u, --git-user             * Git User. "
  echo "   -r, --release-version      * Release Version. "
  echo "   -p, --project-id           * GCP Project Id. "
  echo "${reset}"

  exit 1
}


while [[ $# -gt 0 ]]; do
param="$1"
case $param in
        -v|--build-verion )          VERSION=$2
                       shift # past argument
                       shift # past value
                       ;;
        -d|--build-docker )          BUILD_DOCKER=$2
                       shift # past argument
                       shift # past value
                       ;;
        -k|--git-key )          GIT_KEY=$2
                       shift # past argument
                       shift # past value
                       ;;
        -u|--git-user )          GIT_USER=$2
                       shift # past argument
                       shift # past value
                       ;;
        -r|--release-version )   RELEASE_VERSION=$2
                       shift # past argument
                       shift # past value
                       ;;
        -p|--project-id )   PROJECT_ID=$2
                       shift # past argument
                       shift # past value
                       ;;					   
        -h|*         ) shift
                       shift
                       usage
                       exit
    esac
done

while [ "$VERSION" = "" ]
do
    read  -p "${blue}Build Version [latest]:${reset}" VERSION
    if [[ "$VERSION" = "" ]]; then
     VERSION="latest"
    fi
done

while [ "$GIT_KEY" = "" ]
do
    read  -p "${blue}Git Key :${reset}" GIT_KEY
done

while [ "$GIT_USER" = "" ]
do
    read  -p "${blue}Git User :${reset}" GIT_USER
done

while [ "$RELEASE_VERSION" = "" ]
do
    read  -p "${blue}Release Version :${reset}" RELEASE_VERSION
done

while [ "$PROJECT_ID" = "" ]
do
    read  -p "${blue}Project Id :${reset}" PROJECT_ID
done

while [ "$BUILD_DOCKER" = "" ]
do
	read  -p "${blue}Do you want to build docker images[Y/n] :${reset}" BUILD_DOCKER

	if [[ "$BUILD_DOCKER" = "" ]]; then
		BUILD_DOCKER="y"
	fi
done
#Build and deploy all docker images with the version supplied

if [[ "$BUILD_DOCKER" == "y" ]]; then
	../docker/edgemicro/dockerbuild.sh $VERSION $PROJECT_ID
	../docker/edgemicro_sidecar_injector/dockerbuild.sh $VERSION $PROJECT_ID
	../docker/edgemicro_apigee_setup/dockerbuild.sh $VERSION $PROJECT_ID
	../docker/edgemicro_proxy_init/dockerbuild.sh $VERSION $PROJECT_ID
	../docker/helloworld/dockerbuild.sh $VERSION $PROJECT_ID
fi


curl -s -S -X POST -o $RESPONSE_FILE -u  $GIT_USER:$GIT_KEY "https://api.github.com/repos/${ORG}/${REPO}/releases" \
-H 'Content-Type:application/json' \
-d "{
  \"tag_name\": \"${RELEASE_VERSION}\",
  \"target_commitish\": \"master\",
  \"name\": \"${RELEASE_VERSION}\",
  \"body\": \"Draft Release\",
  \"draft\": false,
  \"prerelease\": false
}"


echo $RESPONSE_FILE

RELEASE_ID=$(cat $RESPONSE_FILE | jq .id)
UPLOAD_URL=$(cat $RESPONSE_FILE | jq .upload_url)

UPLOAD_URL=$(echo $UPLOAD_URL | sed 's/{?name,label}//g')
UPLOAD_URL=$(echo $UPLOAD_URL | sed 's/\"//g')


## Create a temp directory and move all install files here
rm -fr tmp 
mkdir -p tmp

release_os=("darwinamd64" "darwin386" "linux386" "linuxamd64")
#release_os=("darwinamd64")

for os in "${release_os[@]}"; 
	do echo ${os};
	mkdir -p tmp/edgemicro-k8-${RELEASE_VERSION}-${os}
	mkdir -p tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/bin
	cp -fr ../install tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/install
	cp -fr ../samples tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/samples
	cp version.txt tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/
	echo $RELEASE_VERSION > tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/version.txt

	# Replace version information
	sed -i.bak s/latest/$VERSION/g tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/install/kubernetes/edgemicro-sidecar-injector-configmap-release.yaml
	sed -i.bak s/latest/$VERSION/g tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/install/kubernetes/edgemicro-sidecar-injector.yaml

	rm -fr tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/install/kubernetes/edgemicro-sidecar-injector-configmap-release.yaml.bak
	rm -fr tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/install/kubernetes/edgemicro-sidecar-injector.yaml.bak
  
  curl $edgemicroctlDist/${os}/edgemicroctl -o   tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/bin/edgemicroctl
	chmod +x tmp/edgemicro-k8-${RELEASE_VERSION}-${os}/bin/edgemicroctl

	cd tmp

	tar -czvf edgemicro-k8-${RELEASE_VERSION}-${os}.tar.gz edgemicro-k8-${RELEASE_VERSION}-${os}

	
	EDGEMICRO_UPLOAD_URL=$UPLOAD_URL?name=edgemicro-k8-${RELEASE_VERSION}-${os}.tar.gz
	curl -X POST $EDGEMICRO_UPLOAD_URL -u  $GIT_USER:$GIT_KEY \
-H "Content-Type:application/octet-stream" --data-binary @edgemicro-k8-${RELEASE_VERSION}-${os}.tar.gz

	rm -fr edgemicro-k8-${RELEASE_VERSION}-${os}
	cd ..

done

rm -fr tmp
