
## Helloworld Sample

Once you have Installed edgemicro-k8, you can execute following commands:

```
npm install edgemicro -g
edgemicro init
edgemicro configure -o <org> -e <env> -u <user> -p <password>

kubectl apply -f <(edgemicroctl -org=<org> -env=<env> -key=<edgemicro-key> -sec=<edgemicro-sec> -user=<apigee-user> -pass=<apigee-password> -conf=<file path of org-env-config.yaml> -svc=samples/helloworld/helloworld.yaml)
```


#### Accessing Service

```
kubectl get services -n default
```

```
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
helloworld   NodePort    10.19.251.15   <none>        8081:30723/TCP   1m
kubernetes   ClusterIP   10.19.240.1    <none>        443/TCP          9m
```

Get the ingress gateway IP address

```
kubectl get ing -o wide
```
```
NAME      HOSTS     ADDRESS        PORTS     AGE
gateway   *         35.226.55.56   80        1m
```

```
export GATEWAY_IP=$(kubectl describe ing gateway --namespace default | grep "Address" | cut -d ':' -f2 | tr -d "[:space:]")

echo $GATEWAY_IP

echo "Call with no API Key:"
curl $GATEWAY_IP:80;
```
Go to Edge UI and you can see a API and API Product created. Create a app and associate with the product created. Get the api key of the app created.

```
echo "Call with API Key:"
curl -H 'x-api-key:your-edge-api-key' $GATEWAY_IP:80;echo
```

### Uninstalling app

```
kubectl delete -f <(edgemicroctl -org=<org> -env=<env> -key=<edgemicro-key> -sec=<edgemicro-sec> -user=<apigee-user> -pass=<apigee-password> -conf=<file path of org-env-config.yaml> -svc=samples/helloworld/helloworld.yaml)
```


