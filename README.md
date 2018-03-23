# Edgemicro-k8

## Overview

This project allows you to install Apigee Edge Microgateway as a sidecar gateway in front of your services deployed in kubernetes cluster. Developers faces challenges in exposing their microservices and rely on API Management providers for exposing,securing and managing their apis.
This project brings native api management to the microservices development on kubernetes platform.

# Architecture
![Architecture](/docs/images/arch.png)


## Quick Start

### Prerequisites

* Kubernetes version 1.9 or greater
* Kubernetes CLI kubectl v1.9 or greater
* Cluster with atleast 3 nodes having 2 VCPU each.
* Minikube - Coming soon ...
* GKE
   - Create container cluster in GKE with atleast 3 node and machine size having 2 VCPU each.
   ![GKE](/docs/images/gke-container.png)

   - Retrieve your credentials for kubectl (replace <cluster-name> with the name of the cluster you want to use, and <zone> with the zone where that cluster is located):
     ```
     gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-name>
     ```
   - Grant cluster admin permissions to the current user (admin permissions are required to create the necessary RBAC rules for Istio):
     ```
     kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)
     ```
* Openshift - Coming soon ...

### Installation Steps

1. If you are using a MacOS or Linux system, you can also run the following command to download and extract the latest release automatically:
      ```
        curl -L https://git.io/getLatestEdgemicroK8 | sh - 
      ```
2. It extracts the package in the current location with a folder named edgemicro-k8-<os>-<arch>
  * Installation .yaml files for Kubernetes in install/
  * Sample applications in samples/
  * The edgemicroctl client binary in the bin/ directory. edgemicroctl is used when manually injecting Edgemicro as a sidecar gateay.

3.  Change directory to edgemicro-k8 package. For example, if the package is edgemicro-k8-0.1-darwinamd64
    ```
    cd  edgemicro-k8-0.1-darwinamd64
    ```
4.  Add the edgemicroctl client to your PATH. For example, run the following command on a MacOS or Linux
system:
    ```
    export PATH=$PWD/bin:$PATH
    ```
5. Install the base edgemicro-k8 setup. This will create edgemicro-system namespaces and create cluster roles for edgemicro sidecar gateway.

    ```
    kubectl apply -f install/kubernetes/edgemicro.yaml
    ```

6. if you are using GKE, confgure nginx ingress controller.
    ```
    kubectl apply -f install/kubernetes/edgemicro-nginx-gke.yaml
    ```
    

#### Verify Installation

1. To check if the ingress controller pods have started, run the following command:

    ```
    kubectl get pods --all-namespaces -l app=edgemicro-ingress --watch
    ```
    This takes some time (a minute or two) and may go through cycles of Error and Restarts. Once the operator pods are running, you can cancel the above command by typing Ctrl+C. 
    
    **** Please note that there should not be any other nginx controller running.
2. Ensure the following Kubernetes services are deployed
    ```
    kubectl get svc -n edgemicro-system
    ```
    ```
    NAME                        TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                     AGE
    default-http-backend        ClusterIP      10.19.255.106  <none>         80/TCP                       2h
    edgemicro-ingress           LoadBalancer   10.19.247.156  35.224.24.13   80:30176/TCP,443:32325/TCP   2h
    edgemicro-sidecar-injector  ClusterIP      10.19.240.55   <none>         443/TCP                      2h
    ```
3. Verify all pods are running
    ```
    kubectl get pods -n edgemicro-system
     ```
      ```
    NAME                                            READY     STATUS    RESTARTS   AGE
    default-http-backend-55c6c69b88-jf4tn           1/1       Running   0          3h
    edgemicro-ingress-controller-64444469bf-zw8r4   1/1       Running   3          3h
    edgemicro-sidecar-injector-65d78d5cf9-wv6vm     1/1       Running   0          3h
      ```
  
#### Install and Configure Edgemicro

   - Refer [here](https://docs.apigee.com/api-platform/microgateway/2.5.x/installing-edge-microgateway) for more details about installing edgemicro.

        ```
        npm install edgemicro -g
        edgemicro init
        ```
    - Configure Edgemicro to get Key and Secret.
        ```
        edgemicro configure -o <org> -e <env> -u <user> -p <password>
        ```
    - Note down the key and secret generated. It also generates org-env-config.yaml file.

#### Deploying Application

You can now deploy your own application or one of the sample applications provided with the installation like helloworld. Note: the application must use HTTP/1.1 or HTTP/2.0 protocol for all its HTTP traffic because HTTP/1.0 is not supported.

If you started the edgemicro-sidecar-injector, as shown above, you can deploy the application directly using kubectl create. The steps for automatic sidecar injection is mentioned in sections below:

If you do not have the edgemicro-sidecar-injector installed, you must use edgemictoctl to manuallly inject Edgemicro containers in your application pods before deploying them:

```
kubectl apply -f <(edgemicroctl -org=<org> -env=<env> -key=<edgemicro-key> -sec=<edgemicro-sec> -user=<apigee-user> -pass=<apigee-password> -conf=<file path of org-env-config.yaml> -svc=<your-app-spec>.yaml)
```

### Helloworld sample
[here](/docs/helloworld.md)

### Automatic Sidecar Injection
[here](/docs/automatic_sidecar.md)

### Running Bookinfo sample
[here](/docs/bookinfo.md)


### Assumptions
- It uses app labels in services to identify the deployment. Please ensure you define your services with label app. Refer to examples in helloworld and bookinfo example.
- At this point, it also expects service port and container port to be same. Refer examples for more details.


## Uninstall EdgemicroK8
```
kubectl delete -f install/kubernetes/edgemicro-nginx-gke.yaml
kubectl delete -f install/kubernetes/edgemicro.yaml
gcloud beta container clusters delete edge-micro

```

## References
It uses istio-sidecar-proxy-injector and istio-init docker from istio project.

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
