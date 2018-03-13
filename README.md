# edgemicro-k8


### Getting Started

#### Install nodejs and edgemicro

Refer here for more details : https://docs.apigee.com/api-platform/microgateway/2.5.x/installing-edge-microgateway 
Install edgemicro in Local machine - npm install edgemicro -g


### Initialize Containers. 

```

gcloud container clusters create edge-micro  --cluster-version=1.9.2-gke.1 --zone us-central1-a --project edge-apigee --num-nodes 4

gcloud container clusters get-credentials edge-micro --zone us-central1-a --project edge-apigee
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)

```


### Automatic sidecar injection


#### Installing the webhook

Install the base edgemicro

```
kubectl apply -f install/kubernetes/edgemicro.yaml
./install/kubernetes/webhook-edgemicro-patch.sh
```
The above step configures a edge micro

Webhooks requires a signed cert/key pair. Use install/kubernetes/webhook-create-signed-cert.sh to generate a cert/key pair signed by the Kubernetes’ CA. The resulting cert/key file is stored as a Kubernetes secret for the sidecar injector webhook to consume.

Note: Kubernetes CA approval requires permissions to create and approve CSR. See https://kubernetes.io/docs/tasks/tls/managing-tls-in-a-cluster and install/kubernetes/webhook-create-signed-cert.sh for more information.

```
./install/kubernetes/webhook-create-signed-cert.sh \
    --service edgemicro-sidecar-injector \
    --namespace edgemicro-system \
    --secret sidecar-injector-certs
```
Install the sidecar injection configmap.


```
kubectl apply -f install/kubernetes/edgemicro-sidecar-injector-configmap-release-bundle.yaml
```

Set the caBundle in the webhook install YAML that the Kubernetes api-server uses to invoke the webhook.

```
cat install/kubernetes/edgemicro-sidecar-injector.yaml | \
     ./install/kubernetes/webhook-patch-ca-bundle.sh > \
     install/kubernetes/edgemicro-sidecar-injector-with-ca-bundle.yaml

```

Install the sidecar injector webhook.

```
kubectl apply -f install/kubernetes/edgemicro-sidecar-injector-with-ca-bundle.yaml

```

The sidecar injector webhook should now be running.

```
kubectl -n edgemicro-system get deployment -ledgemicro=sidecar-injector

NAME                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
edgemicro-sidecar-injector   1         1         1            1           12m

```

The sidecar injector pod should look like 

```
kubectl get pods -n edgemicro-system

NAME                                          READY     STATUS    RESTARTS   AGE
edgemicro-sidecar-injector-78bffbd44b-bct2r   1/1       Running   0          14m
```

NamespaceSelector decides whether to run the webhook on an object based on whether the namespace for that object matches the selector (see https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors). The default webhook configuration uses edgemicro-injection=enabled.

```
kubectl get namespace -L edgemicro-injection

AME               STATUS    AGE       EDGEMICRO-INJECTION
default            Active    1d        
edgemicro-system   Active    1d
kube-public        Active    1d
kube-system        Active    1d
```


Label the default namespace with edgemicro-injection=enabled

```
kubectl label namespace default edgemicro-injection=enabled
kubectl get namespace -L edgemicro-injection

AME               STATUS    AGE       EDGEMICRO-INJECTION
default            Active    1d        enabled
edgemicro-system   Active    1d
kube-public        Active    1d
kube-system        Active    1d

```

#### Deploying the helloworld app

```
kubectl apply -f samples/helloworld/helloworld.yaml
kubectl get pods

NAME                          READY     STATUS    RESTARTS   AGE
helloworld-569d6565f9-lwrrv   2/2       Running   0          17m

```

#### Accessing the services
```
kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
helloworld   LoadBalancer   10.19.252.245   35.188.24.156   8081:32296/TCP   24m
kubernetes   ClusterIP      10.19.240.1     <none>          443/TCP          1d
```

Wiat till the External IP of Service shows up

```
export GATEWAY_IP=$(kubectl describe services helloworld | grep "LoadBalancer Ingres" | cut -d ':' -f2 | tr -d "[:space:]")

echo $GATEWAY_IP

echo "Call with no API Key:"
curl $GATEWAY_IP:8081/hello;echo
echo "Call with API Key:"
curl -H 'x-api-key:your-edge-api-key' $GATEWAY_IP:8081/hello;echo
```


## Deleting the setup
```
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



