#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`
reset=`tput sgr0`

usage() {

  echo "${blue}Usage: $0 [option...]" >&2
  echo
  echo "   -o, --apigee_org           * Apigee Organization. "
  echo "   -e, --apigee_env           * Apigee Environment. "
  echo "   -v, --virtual_host         * Virtual Hosts with comma seperated values.The values are like default,secure. "
  echo "   -t, --private              y,if you are configuring Private Cloud. Default is n."
  echo "   -m, --mgmt_url             Management API URL needed if its Private Cloud"
  echo "   -r, --api_base_path        API Base path needed if its Private Cloud"
  echo "   -u, --user                 * Apigee Admin Email"
  echo "   -p, --password             * Apigee Admin Password"
  echo "   -n, --namespace            Namespace where your application is deployed. Default is default"
  echo "   -k, --key                  * Edgemicro Key. If not specified it will generate."
  echo "   -s, --secret               * Edgemicro Secret. If not specified it will generate."
  echo "   -c, --config_file          * Specify the path of org-env-config.yaml. If not specified it will generate in ./install/kubernetes/config directory"

  echo "${reset}"

  exit 1
}


while [[ $# -gt 0 ]]; do
param="$1"
case $param in
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
        -n|--namespace ) namespace=$2
                       shift # past argument
                       shift # past value
                       ;;
        -s|--secret )     secret=$2
                       shift # past argument
                       shift # past value
                       ;;
        -k|--key )        key=$2
                       shift # past argument
                       shift # past value
                       ;;
        -c|--config_file )   config_file=$2
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

while [ "$namespace" = "" ]
do
    read  -p "${blue}Namespace to deploy application [default]:${reset}" namespace
    if [[ "$namespace" = "" ]]; then
     namespace="default"
    fi
done


while [ "$adminEmail" = "" ]
do
  read  -p "${blue}Apigee username [required]:${reset}" adminEmail
done

while [ "$adminPasswd" = "" ]
do
    read -s -p "${blue}Apigee password [required]:${reset}" adminPasswd
    echo
done

while [ "$org_name" = "" ]
do
  read  -p "${blue}Apigee organization [required]:${reset}" org_name
done

while [ "$env_name" = "" ]
do
  read  -p "${blue}Apigee environment [required]:${reset}" env_name
done

while [ "$vhost_name" = "" ]
do
    read  -p "${blue}Virtual Host [required]:${reset}" vhost_name
done


while [ "$isPrivate" = "" ]
do
  read -p "${blue}Is this Private Cloud (\"n\",\"y\") [N/y]:${reset}" isPrivate
  if [[ "$isPrivate" = "" ]]; then
     isPrivate="n"
  fi
done

if [ "${isPrivate}" == "y" ]; then
  while [[ "$mgmt_url" = "" ]]
  do
      read -p "${blue}Apigee Management Url:${reset}" mgmt_url
  done

  while [[ "$api_base_path" = "" ]]
  do
      read -p "${blue}Apigee API Endpoint Url:${reset}"  api_base_path
  done
else
    mgmt_url="https://api.enterprise.apigee.com"
fi

if [ "$key" = "" ]; then
  read -p "${blue}Edgemicro Key. Press Enter to generate:${reset}" key
fi
if [ "$secret" = "" ]; then
  read -p "${blue}Edgemicro Secret. Press Enter to generate:${reset}" secret
fi
if [ "$config_file" = "" ]; then
  read -p "${blue}Edgemicro org-env-config.yaml. Press Enter to generate:${reset}" config_file
fi


generate_key="n"

if [[ -n "$key" && -n "$secret" && -n "$config_file" ]] ; then
  generate_key="n"
else  
  if [[ -n "$key" || -n "$secret" || -n "$config_file" ]] ; then
    echo
    echo "${red}key,secret and config_file should all be provided together!!!.${reset}"
    echo
    usage
  else
    generate_key="y"
  fi
fi


if [ "${generate_key}" == "y" ]; then
  edgemicro init
  rm -fr $PWD/install/kubernetes/micro.txt
  if [ "${isPrivate}" == "y" ]; then
    echo "Configure for Private Cloud"
    edgemicro private configure -o ${org_name} -e ${env_name} -u ${adminEmail} -p ${adminPasswd} -r ${api_base_path} -m ${mgmt_url} -v ${vhost_name} > $PWD/install/kubernetes/micro.txt
  else
    echo "Configure for Cloud"
    edgemicro configure -o ${org_name} -e ${env_name} -u ${adminEmail} -p ${adminPasswd} -v ${vhost_name} > $PWD/install/kubernetes/micro.txt
  fi

  cp -fr ~/.edgemicro/${org_name}-${env_name}-config.yaml $PWD/install/kubernetes/config/
  export key=$(cat $PWD/install/kubernetes/micro.txt | grep key:| cut -d':' -f2 | sed -e 's/^[ \t]*//')
  export secret=$(cat $PWD/install/kubernetes/micro.txt | grep secret:| cut -d':' -f2 | sed -e 's/^[ \t]*//')

  rm -fr $PWD/install/kubernetes/micro.txt

  echo "${red}******************************************************************************************"
  echo "${red}Config file is Generated in $PWD/config directory."
  echo "${red}"
  echo "${red}Please make changes as desired."
  echo "${red}*****************************************************************************************${reset}"

  while [ "${agree_to_decorate}" != "y" ]
  do
      read  -p "Do you agree to proceed(\"n\",\"y\") [N/y]:" agree_to_decorate
      if [[ "${agree_to_decorate}" = "n" ]]; then
          exit 0;
      fi
  done

else
  #copy the config file to config directory
  cp -fr ${config_file} $PWD/install/kubernetes/config/${org_name}-${env_name}-config.yaml
fi

echo
echo Configuring Microgateway with
echo
echo key:${blue}$key${reset}
echo secret:${blue}$secret${reset}
echo config:${blue}$PWD/install/kubernetes/config/${org_name}-${env_name}-config.yaml${reset}
echo

#Export Al variables in Environment Variabe
export EDGEMICRO_NAMESPACE=$(echo -n "$namespace")
export EDGEMICRO_ORG=$(echo -n "$org_name" | base64)
export EDGEMICRO_ENV=$(echo -n "$env_name" | base64)
export EDGEMICRO_KEY=$(echo -n "$key" | base64)
export EDGEMICRO_SECRET=$(echo -n "$secret" | base64)
export EDGEMICRO_ADMINEMAIL=$(echo -n "$adminEmail" | base64)
export EDGEMICRO_ADMINPASSWORD=$(echo -n "$adminPasswd" | base64)
export EDGEMICRO_MGMTURL=$(echo -n "$mgmt_url" | base64)
export EDGEMICRO_CONFIG=$(cat $PWD/install/kubernetes/config/${org_name}-${env_name}-config.yaml | base64 | base64)


cp -fr $PWD/install/kubernetes/edgemicro-config-namespace.yaml  $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_NAMESPACE}/${EDGEMICRO_NAMESPACE}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_ORG}/${EDGEMICRO_ORG}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_ENV}/${EDGEMICRO_ENV}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_KEY}/${EDGEMICRO_KEY}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_SECRET}/${EDGEMICRO_SECRET}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_MGMTURL}/${EDGEMICRO_MGMTURL}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_ADMINEMAIL}/${EDGEMICRO_ADMINEMAIL}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_ADMINPASSWORD}/${EDGEMICRO_ADMINPASSWORD}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml
sed -i.bak s/\${EDGEMICRO_CONFIG}/${EDGEMICRO_CONFIG}/g $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml

rm -fr $PWD/install/kubernetes/edgemicro-config-namespace-bundle.yaml.bak

echo "${green}********************************************************************************************************"
echo "${green}Updated config properties in install/kubernetes/edgemicro-config-namespace-bundle.yaml"
echo "${green}********************************************************************************************************${reset}"
