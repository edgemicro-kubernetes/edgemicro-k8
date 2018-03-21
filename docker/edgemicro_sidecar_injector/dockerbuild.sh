
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -ne 1 ]; then 
	echo "Please Provide Verson Number to build"
fi

version=$1

docker pull docker.io/istio/sidecar_injector:0.6.0
docker tag docker.io/istio/sidecar_injector:0.6.0 edgemicrok8/sidecar_injector:$version
docker push edgemicrok8/sidecar_injector:$version
