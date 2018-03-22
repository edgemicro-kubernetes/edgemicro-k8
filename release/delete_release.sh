#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`
reset=`tput sgr0`

ORG=edgemicro-kubernetes
REPO=edgemicro-k8

usage() {

  echo "${blue}Usage: $0 [option...]" >&2
  echo
  echo "   -k, --git-key              * Git Key. "
  echo "   -u, --git-user             * Git User. "
  echo "   -r, --release-version      * Release Version. "

  echo "${reset}"

  exit 1
}


while [[ $# -gt 0 ]]; do
param="$1"
case $param in
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
        -h|*         ) shift
                       shift
                       usage
                       exit
    esac
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

curl -u $GIT_USER:$GIT_KEY https://api.github.com/repos/${ORG}/${REPO}/git/refs/tags/$RELEASE_VERSION -X DELETE
ID=$(curl -s -S -u $GIT_USER:$GIT_KEY https://api.github.com/repos/${ORG}/${REPO}/releases | jq .[].id)
curl -u $GIT_USER:$GIT_KEY https://api.github.com/repos/${ORG}/${REPO}/releases/$ID -X DELETE
