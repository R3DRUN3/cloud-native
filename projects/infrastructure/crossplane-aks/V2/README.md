# AKS COMPOSITION PoC

AKS Crossplane composition proof of concept.


## Abstract
The goal of this repo is to deploy the same resources as in the <a href="https://github.com/R3DRUN3/cloud-native/tree/main/projects/infrastructure/crossplane-aks">parent</a> repo but using Crossplane `Compositions` instead of simple `managed resources`.

## Requirements
- *azure account*
- *azure-cli*
- *jq*
- *docker*
- *kind*
- *kubectl*

## Instructions
To install `upbound cli` run this install script:  
```console
curl -sL https://cli.upbound.io | sh
```

See [up docs](https://docs.upbound.io/cli/) for more install options.
<br/>

For installing the platform we need a running Crossplane control plane. We are
using [Universal Crossplane (UXP)
](https://github.com/upbound/universal-crossplane). Ensure that your kubectl
context is pointing to the correct Kubernetes cluster or for example create a
[kind](https://kind.sigs.k8s.io) cluster:

```console
kind create cluster
```

Finally install UXP into the `upbound-system` namespace:

```console
up uxp install
```

You can validate the install by inspecting all installed components:

```console
kubectl get all -n upbound-system
```

<br/>


Now configure *azure provider* and *helm provider*:  
```console
chmod +x providers/configure-azure-provider.sh && sh providers/configure-azure-provider.sh
```

<br/>

Apply all compositions:  
```console
kubectl apply -f package --recursive 
```

<br/>


Now go ahead and create a custom defined cluster:  
```console
kubectl apply -f examples/cluster-claim.yaml
```

<br/>

Check for managed resources:  
```console
❯ watch kubectl get managed

Every 2.0s: kubectl get managed                                                                                                                                  KPDOIT26.local: Thu Jan 19 09:22:02 2023

NAME                                                READY   SYNCED   EXTERNAL-NAME        AGE
resourcegroup.azure.upbound.io/azure-aks-stack-rg   True    True     azure-aks-stack-rg   63s

NAME                                               CHART   VERSION   SYNCED   READY   STATE   REVISION   DESCRIPTION   AGE
release.helm.crossplane.io/azure-aks-stack-vault   vault   0.22.1    False                                             63s

NAME                                                                      READY   SYNCED   EXTERNAL-NAME         AGE
kubernetescluster.containerservice.azure.upbound.io/azure-aks-stack-aks   False   True     azure-aks-stack-aks   63s

NAME                                                           READY   SYNCED   EXTERNAL-NAME          AGE
virtualnetwork.network.azure.upbound.io/azure-aks-stack-vnet   True    True     azure-aks-stack-vnet   63s

NAME                                                 READY   SYNCED   EXTERNAL-NAME        AGE
subnet.network.azure.upbound.io/azure-aks-stack-sn   True    True     azure-aks-stack-sn   63s
```

<br/>

You can inspect your cluster on your azure web console:  
<div style="width: 65%; height: 65%">

  ![](images/aks.png)
  
</div>
<br/>

And inside the created resource group we can see our Vnet and our cluster:  
<div style="width: 65%; height: 65%">

  ![](images/rc.png)
  
</div>
<br/>




Now we can export our aks kubeconfig:  
```console
az aks get-credentials --resource-group azure-aks-stack-rg --name azure-aks-stack-aks --file kubeconfig-aks
```

<br/>

And change kubectl context:  
```console
export KUBECONFIG=kubeconfig-aks
```

<br/>

Now you can inspect your aks cluster with kubectl, for example:  
```console
echo "\n\nRetrieving cluster nodes:" \
&& kubectl get nodes \
&& echo "\n\nRetrieving cluster namespaces:" \
&& kubectl get namespaces \
&& echo "\n\nRetrieving pods in the 'vault' namespace:" \
&& kubectl get pods -n vault
```

<br/>

Output:  
```console
Retrieving cluster nodes:
NAME                              STATUS   ROLES   AGE   VERSION
aks-default-20610590-vmss000000   Ready    agent   15m   v1.24.3
aks-default-20610590-vmss000001   Ready    agent   15m   v1.24.3
aks-default-20610590-vmss000002   Ready    agent   15m   v1.24.3


Retrieving cluster namespaces:
NAME              STATUS   AGE
default           Active   16m
kube-node-lease   Active   16m
kube-public       Active   16m
kube-system       Active   16m
vault             Active   13m


Retrieving pods in the 'vault' namespace:
NAME                                                  READY   STATUS    RESTARTS   AGE
azure-aks-stack-vault-0                               0/1     Running   0          12m
azure-aks-stack-vault-1                               0/1     Running   0          12m
azure-aks-stack-vault-2                               0/1     Running   0          12m
azure-aks-stack-vault-agent-injector-68797cf5-jsqnt   1/1     Running   0          13m
```

<br/>

Note that all the vault pods shows 0/1 because vault is sealed.
<br/>
In order to unseal it we can either use *kubectl exec* or the vault *web ui*.
<br/>
To do it via kubectl, take a look at <a href="https://github.com/R3DRUN3/cyberhall/tree/main/k8s-security/k8s-vault/demo-1">this</a> repo.
<br/>
To do it via web ui, take a look at <a href="https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-azure-aks">this</a> guide.
<br/>
<br/>

To see the vault ui ip (Load Balancer):  
```console
❯ kubectl -n vault get service azure-aks-stack-vault-ui

NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
azure-aks-stack-vault-ui   LoadBalancer   10.0.234.134   20.126.170.11   8200:31388/TCP   7m30s
```

<br/>

If you reach that *EXTERNAL-IP* address via browser:  
<div style="width: 65%; height: 65%">

  ![](images/vault-web-ui.png)
  
</div>
<br/>


To delete all created resources run the following command:  
```console
kubectl delete -f examples/cluster-claim.yaml
```

<br/>









