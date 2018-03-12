#!/bin/bash

#This is where we configure edge micro.

#!/bin/bash 
usage() {
  echo 
  echo './edgemicro-hook.sh --private n|y -o org -e env -m mgmt_url -r runtime_api -u adminEmail -p adminPassword -v virtual_host'
  echo
  exit
}
lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}
getOS() {
  
  OS=`lowercase \`uname\``
  if [ "${OS}" == "windowsnt" ]; then
      OS=windows
  elif [ "${OS}" == "darwin" ]; then
      OS=mac
  else
      OS=`uname`
      if [ "${OS}" == "Linux" ] ; then
          OS=$(cat /etc/*release | grep ^NAME | tr -d 'NAME="')
          if [ "{$OS}" == "Ubuntu" ] ; then
              OS=ubuntu
          else 
            OS=fedora
          fi
          OS=`lowercase $OS`
      fi
  fi
  echo ${OS}
}


while [[ $# -gt 0 ]]; do
key="$1"
case $key in
        -o|--apigee_org )           org_name=$2
                       shift # past argument
                       shift # past value
                       ;;
        -e|--apigee_env )           env_name=$2
                       shift # past argument
                       shift # past value
                       ;;
        -m|--mgmt_url )           mgmt_url=$2
                       shift # past argument
                       shift # past value
                       ;;
        -v|--virtual_host)           vhost_name=$2
                       shift # past argument
                       shift # past value
                       ;;
        -r|--api_base_path )           api_base_path=$2
                       shift # past argument
                       shift # past value
                       ;;
        -u|--user )           adminEmail=$2
                       shift # past argument
                       shift # past value
                       ;;
        -p|--password )           adminPasswd=$2
                       shift # past argument
                       shift # past value
                       ;;
        -t|--private ) isPrivate=$2
                       shift # past argument
                       shift # past value
                       ;;
        -h|*         ) shift
                       shift
                       usage
                       exit
    esac
done

#Validation

while [ "$adminEmail" = "" ]
do
  read  -p "Apigee username [required]:" adminEmail
done

while [ "$adminPasswd" = "" ]
do
    read -s -p "Apigee password [required]:" adminPasswd
    echo
done

while [ "$org_name" = "" ]
do
  read  -p "Apigee organization [required]:" org_name
done

while [ "$env_name" = "" ]
do
  read  -p "Apigee environment [required]:" env_name
done

while [ "$vhost_name" = "" ]
do
    read  -p "Virtual Host:" vhost_name
done


while [ "$isPrivate" = "" ]
do
  read -p "Is this Private Cloud (\"n\",\"y\") [N/y]:" isPrivate
  if [[ "$isPrivate" = "" ]]; then
     isPrivate="n"
  fi
done

if [ "${isPrivate}" == "y" ]; then
  while [[ "$mgmt_url" = "" ]]
  do
      read -p "Apigee Management Url:" mgmt_url
  done

  while [[ "$api_base_path" = "" ]]
  do
      read -p "Apigee API Endpoint Url:"  api_base_path
  done
fi


echo 'isPrivate '$isPrivate

edgemicro init
rm -fr /tmp/micro.txt
if [ "${isPrivate}" == "y" ]; then
  echo "isPrivate"
  edgemicro private configure -o ${org_name} -e ${env_name} -u ${adminEmail} -p ${adminPasswd} -r ${api_base_path} -m ${mgmt_url} -v ${vhost_name} > /tmp/micro.txt
else
  echo "It's an edge"
  edgemicro configure -o ${org_name} -e ${env_name} -u ${adminEmail} -p ${adminPasswd} -v ${vhost_name} > /tmp/micro.txt 
fi

cp -fr ~/.edgemicro/${org_name}-${env_name}-config.yaml $PWD/install/kubernetes/config/

export key=$(cat /tmp/micro.txt | grep key:| cut -d':' -f2 | sed -e 's/^[ \t]*//')
export secret=$(cat /tmp/micro.txt | grep secret:| cut -d':' -f2 | sed -e 's/^[ \t]*//')

echo key:$key
echo secret:$secret


echo "Config file is Generated in $PWD/config directory. Please modify as desired"

while [ "${agree_to_decorate}" != "y" ]
do
    read  -p "Do you agree to proceed(\"n\",\"y\") [N/y]:" agree_to_decorate
done

#Export Al variables in Environment Variabe
export EDGEMICRO_ORG=$(echo -n "$org_name" | base64)
export EDGEMICRO_ENV=$(echo -n "$env_name" | base64)
export EDGEMICRO_KEY=$(echo -n "$key" | base64)
export EDGEMICRO_SECRET=$(echo -n "$secret" | base64 | base64)
export EDGEMICRO_CONFIG=$(cat $PWD/install/kubernetes/config/${org_name}-${env_name}-config.yaml | base64)


echo $EDGEMICRO_ORG
echo $EDGEMICRO_ENV
echo $EDGEMICRO_KEY
echo $EDGEMICRO_SECRET
echo $EDGEMICRO_CONFIG


cp -fr $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release.yaml  $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
sed -i.bak "s|\${EDGEMICRO_ORG}|${EDGEMICRO_ORG}|g" $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
sed -i.bak "s|\${EDGEMICRO_ENV}|${EDGEMICRO_ENV}|g" $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
sed -i.bak "s|\${EDGEMICRO_KEY}|${EDGEMICRO_KEY}|g" $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
sed -i.bak "s|\${EDGEMICRO_SECRET}|${EDGEMICRO_SECRET}|g" $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
sed -i.bak "s|\${PWD}|${PWD}|g" $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
sed -i.bak "s|\${EDGEMICRO_CONFIG}|${EDGEMICRO_CONFIG}|g" $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml

rm -fr $PWD/install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml.bak
