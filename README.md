# edgemicro-k8


### Getting Started

```

Install supported nodejs of edgemicro
Install edgemicro in Local machine - npm install edgemicro -g


gcloud container clusters create edge-micro  --cluster-version=1.9.2-gke.1 --zone us-central1-a --project edge-apigee --num-nodes 4

gcloud container clusters get-credentials edge-micro --zone us-central1-a --project edge-apigee
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)

kubectl apply -f install/kubernetes/edgemicro.yaml

./install/kubernetes/webhook-create-signed-cert.sh \
    --service edgemicro-sidecar-injector \
    --namespace edgemicro-system \
    --secret sidecar-injector-certs

./install/kubernetes/webhook-edgemicro-patch.sh

kubectl apply -f install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml

rm -fr install/kubernetes/edgemicro-sidecar-injector-with-ca-bundle.yaml

cat install/kubernetes/edgemicro-sidecar-injector.yaml | \
     ./install/kubernetes/webhook-patch-ca-bundle.sh > \
     install/kubernetes/edgemicro-sidecar-injector-with-ca-bundle.yaml

kubectl apply -f install/kubernetes/edgemicro-sidecar-injector-with-ca-bundle.yaml

kubectl -n edgemicro-system get deployment -ledgemicro=sidecar-injector
kubectl get pods -n edgemicro-system

kubectl label namespace default edgemicro-injection=enabled
kubectl get namespace -L edgemicro-injection

kubectl apply -f samples/helloworld/helloworld.yaml
kubectl get pods

kubectl delete service helloworld
kubectl expose deployment helloworld --type="LoadBalancer" --port=8000
kubectl get services

###Wiat till Services show up
export GATEWAY_IP=$(kubectl describe services helloworld | grep "LoadBalancer Ingres" | cut -d ':' -f2 | tr -d "[:space:]")

echo $GATEWAY_IP

echo "Call with no API Key:"
curl $GATEWAY_IP:8000/hello;echo
echo "Call with API Key:"
curl -H 'x-api-key:RcH5cjEeoND1zMGFGTIymv0okvAxjqmn' $GATEWAY_IP:8000/hello;echo

#Deleting the setup
kubectl delete -f samples/helloworld/helloworld.yaml
kubectl delete -f install/kubernetes/edgemicro-sidecar-injector-with-ca-bundle.yaml
kubectl -n edgemicro-system delete secret sidecar-injector-certs
kubectl delete csr edgemicro-sidecar-injector.edgemicro-system
kubectl label namespace default edgemicro-injection-
rm -fr install/kubernetes/edgemicro-sidecar-injector-with-ca-bundle.yaml
kubectl delete -f install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
kubectl delete -f install/kubernetes/edgemicro.yaml

gcloud beta container clusters delete edge-micro

```



