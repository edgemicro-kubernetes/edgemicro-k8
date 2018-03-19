## Running Bookinfo sample

### Create a Edgemicro configuration profile edgemicro

```
./install/kubernetes/webhook-edgemicro-patch.sh -n bookinfo


Apigee username [required]:rajeshmishra@apigee.com
Apigee password [required]:
Apigee organization [required]:gaccelerate5
Apigee environment [required]:test
Virtual Host [required]:default
Is this Private Cloud ("n","y") [N/y]:
Edgemicro Key. Press Enter to generate:
Edgemicro Secret. Press Enter to generate:
Edgemicro org-env-config.yaml. Press Enter to generate:
current nodejs version is v6.10.0
current edgemicro version is 2.5.12
config initialized to /Users/rajeshmi/.edgemicro/default.yaml
Configure for Cloud
******************************************************************************************
Config file is Generated in /Users/rajeshmi/presales/git/edgemicro-k8/config directory.

Please make changes as desired.
*****************************************************************************************
Do you agree to proceed("n","y") [N/y]:

```

Before you agree to proceed, In a new shell edit the generated org-env-config.yaml file generated in directory mentioned above and add spikearrest policy. Change plugin from oauth to spikearrest.


The configuration file would look like:

```
edgemicro:
  port: 8000
  max_connections: 1000
  config_change_poll_interval: 600
  logging:
    level: error
    dir: /var/tmp
    stats_log_interval: 60
    rotate_interval: 24
  plugins:
    sequence:
      - spikearrest
headers:
  x-forwarded-for: true
  x-forwarded-host: true
  x-request-id: true
  x-response-time: true
  via: true
spikearrest:
  timeUnit: minute
  allow: 10
oauth:
  allowNoAuthorization: false
  allowInvalidAuthorization: false
  verify_api_key_url: 'https://gaccelerate5-test.apigee.net/edgemicro-auth/verifyApiKey

```
Go to the previous shell and enter y to finish the setup

```
Do you agree to proceed("n","y") [N/y]:y

Configuring Microgateway with

key:a184353453454645645645675
secret:3453464575667878979808080890
config:/Users/rajeshmi/presales/git/edgemicro-k8/install/kubernetes/config/gaccelerate5-test-config.yaml

********************************************************************************************************
kubectl apply -f install/kubernetes/edgemicro-config-namespace-bundle.yaml
********************************************************************************************************
```

Add edgemicro profile to kubernetes clusters
```
kubectl apply -f install/kubernetes/edgemicro-config-namespace-bundle.yaml
```

#### Enable Injection
```
kubectl label namespace bookinfo edgemicro-injection=enabled
kubectl get namespace -L edgemicro-injection

AME               STATUS    AGE       EDGEMICRO-INJECTION
bookinfo           Active    13s       enabled
default            Active    15h
edgemicro-system   Active    14h
kube-public        Active    15h
kube-system        Active    15h

```

#### Deploy bookinfo app with Injection

```
kubectl apply -f samples/bookinfo/kube/bookinfo.yaml --namespace=bookinfo
kubectl get pods --namespace=bookinfo

NAME                              READY     STATUS    RESTARTS   AGE
details-v1-64b86cd49-rkg8p        2/2       Running   0          1m
productpage-v1-84f77f8747-bwd96   2/2       Running   0          1m
ratings-v1-5f46655b57-vfw4r       2/2       Running   0          1m
reviews-v1-ff6bdb95b-tgwlz        2/2       Running   0          1m
reviews-v2-5799558d68-27hm8       2/2       Running   0          1m
reviews-v3-58ff7d665b-l5k4w       2/2       Running   0          1m

```

#### Accessing the service


```
kubectl get services -n bookinfo

NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.19.245.100   <none>        9080/TCP   6m
productpage   ClusterIP   10.19.249.144   <none>        9080/TCP   6m
ratings       ClusterIP   10.19.250.60    <none>        9080/TCP   6m
reviews       ClusterIP   10.19.249.86    <none>        9080/TCP   6m
```

Get the ingress ip address

```
kubectl get ing -o wide -n bookinfo
NAME      HOSTS     ADDRESS         PORTS     AGE
gateway   *         35.188.95.103   80        6m
```

Go to the browser and hit http://gateway-external-address and hit couple of times. You should see that spikearrest gets engaged.


### Celeberate

Cheers!!! you just deployed your bookinfo sample with edgemicro as sidecar gateway.

### Cleanup
```
kubectl delete -f samples/bookinfo/kube/bookinfo.yaml --namespace=bookinfo
kubectl label namespace bookinfo edgemicro-injection-
```
