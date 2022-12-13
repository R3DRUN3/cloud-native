# SIMPLE DEMO ON HOW TO USE THE KUBENETES GO CLIENT
Use the `client-go` to communicate with your Kubernetes cluster.
<br/>

## Prerequisites
- `docker`
- `minikube`
- `go`

<br/>

## Instructions
Start a minikube cluster with the following command:  
```console
minikube start
```

<br/>

create a new namespace:  
```console
kubectl create namespace client-go
```

<br/>

Start a new `nginx` pod inside this namespace:  
```console
kubectl -n client-go run nginx --image=nginx:latest
```

<br/>

Check that your pod has been deployed:  (CTRL + C to exit the watch mode)
```console
kubectl -n client-go get pods -w

NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          7s
```

<br/>

Now we can launch our simple go program.
<br/>
Our app consiste of a loop that every 100 seconds will connect to the cluster using 
<br/>
our local `kubeconfig` and then it will search the cluster for a pod named `nginx` inside a namespace named `client-go`.
<br/>
If it finds it, it will print the pod's specifications in JSON format.

<br/>

Launch the program:  
```console
go run apitest.go
```

<br/>

Output:   

```console
There are 8 pods in the cluster
Found pod nginx in namespace client-go

Pod Spec:
 {
  "metadata": {
    "name": "nginx",
    "namespace": "client-go",
    "uid": "a6d5899b-3ebb-4f85-a349-63030fc07e0c",
    "resourceVersion": "1317",
    "creationTimestamp": "2022-12-13T12:20:06Z",
    "labels": {
      "run": "nginx"
    },
    "managedFields": [
      {
        "manager": "kubectl-run",
        "operation": "Update",
        "apiVersion": "v1",
        "time": "2022-12-13T12:20:06Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:metadata": {
            "f:labels": {
              ".": {},
              "f:run": {}
            }
          },
          "f:spec": {
            "f:containers": {
              "k:{\"name\":\"nginx\"}": {
                ".": {},
                "f:image": {},
                "f:imagePullPolicy": {},
                "f:name": {},
                "f:resources": {},
                "f:terminationMessagePath": {},
                "f:terminationMessagePolicy": {}
              }
            },
            "f:dnsPolicy": {},
            "f:enableServiceLinks": {},
            "f:restartPolicy": {},
            "f:schedulerName": {},
            "f:securityContext": {},
            "f:terminationGracePeriodSeconds": {}
          }
        }
      },
      {
        "manager": "kubelet",
        "operation": "Update",
        "apiVersion": "v1",
        "time": "2022-12-13T12:20:25Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:status": {
            "f:conditions": {
              "k:{\"type\":\"ContainersReady\"}": {
                ".": {},
                "f:lastProbeTime": {},
                "f:lastTransitionTime": {},
                "f:status": {},
                "f:type": {}
              },
              "k:{\"type\":\"Initialized\"}": {
                ".": {},
                "f:lastProbeTime": {},
                "f:lastTransitionTime": {},
                "f:status": {},
                "f:type": {}
              },
              "k:{\"type\":\"Ready\"}": {
                ".": {},
                "f:lastProbeTime": {},
                "f:lastTransitionTime": {},
                "f:status": {},
                "f:type": {}
              }
            },
            "f:containerStatuses": {},
            "f:hostIP": {},
            "f:phase": {},
            "f:podIP": {},
            "f:podIPs": {
              ".": {},
              "k:{\"ip\":\"172.17.0.3\"}": {
                ".": {},
                "f:ip": {}
              }
            },
            "f:startTime": {}
          }
        },
        "subresource": "status"
      }
    ]
  },
  "spec": {
    "volumes": [
      {
        "name": "kube-api-access-7pdxn",
        "projected": {
          "sources": [
            {
              "serviceAccountToken": {
                "expirationSeconds": 3607,
                "path": "token"
              }
            },
            {
              "configMap": {
                "name": "kube-root-ca.crt",
                "items": [
                  {
                    "key": "ca.crt",
                    "path": "ca.crt"
                  }
                ]
              }
            },
            {
              "downwardAPI": {
                "items": [
                  {
                    "path": "namespace",
                    "fieldRef": {
                      "apiVersion": "v1",
                      "fieldPath": "metadata.namespace"
                    }
                  }
                ]
              }
            }
          ],
          "defaultMode": 420
        }
      }
    ],
    "containers": [
      {
        "name": "nginx",
        "image": "nginx:latest",
        "resources": {},
        "volumeMounts": [
          {
            "name": "kube-api-access-7pdxn",
            "readOnly": true,
            "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount"
          }
        ],
        "terminationMessagePath": "/dev/termination-log",
        "terminationMessagePolicy": "File",
        "imagePullPolicy": "Always"
      }
    ],
    "restartPolicy": "Always",
    "terminationGracePeriodSeconds": 30,
    "dnsPolicy": "ClusterFirst",
    "serviceAccountName": "default",
    "serviceAccount": "default",
    "nodeName": "minikube",
    "securityContext": {},
    "schedulerName": "default-scheduler",
    "tolerations": [
      {
        "key": "node.kubernetes.io/not-ready",
        "operator": "Exists",
        "effect": "NoExecute",
        "tolerationSeconds": 300
      },
      {
        "key": "node.kubernetes.io/unreachable",
        "operator": "Exists",
        "effect": "NoExecute",
        "tolerationSeconds": 300
      }
    ],
    "priority": 0,
    "enableServiceLinks": true,
    "preemptionPolicy": "PreemptLowerPriority"
  },
  "status": {
    "phase": "Running",
    "conditions": [
      {
        "type": "Initialized",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:20:06Z"
      },
      {
        "type": "Ready",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:20:25Z"
      },
      {
        "type": "ContainersReady",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:20:25Z"
      },
      {
        "type": "PodScheduled",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:20:06Z"
      }
    ],
    "hostIP": "192.168.49.2",
    "podIP": "172.17.0.3",
    "podIPs": [
      {
        "ip": "172.17.0.3"
      }
    ],
    "startTime": "2022-12-13T12:20:06Z",
    "containerStatuses": [
❯ go run apitest.go

There are 8 pods in the cluster
Found pod nginx in namespace client-go

Pod Spec:
 {
  "metadata": {
    "name": "nginx",
    "namespace": "client-go",
    "uid": "df912624-2ade-4994-a6ad-c0721e8b04d0",
    "resourceVersion": "2958",
    "creationTimestamp": "2022-12-13T12:58:58Z",
    "labels": {
      "run": "nginx"
    },
    "managedFields": [
      {
        "manager": "kubectl-run",
        "operation": "Update",
        "apiVersion": "v1",
        "time": "2022-12-13T12:58:58Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:metadata": {
            "f:labels": {
              ".": {},
              "f:run": {}
            }
          },
          "f:spec": {
            "f:containers": {
              "k:{\"name\":\"nginx\"}": {
                ".": {},
                "f:image": {},
                "f:imagePullPolicy": {},
                "f:name": {},
                "f:resources": {},
                "f:terminationMessagePath": {},
                "f:terminationMessagePolicy": {}
              }
            },
            "f:dnsPolicy": {},
            "f:enableServiceLinks": {},
            "f:restartPolicy": {},
            "f:schedulerName": {},
            "f:securityContext": {},
            "f:terminationGracePeriodSeconds": {}
          }
        }
      },
      {
        "manager": "kubelet",
        "operation": "Update",
        "apiVersion": "v1",
        "time": "2022-12-13T12:59:01Z",
        "fieldsType": "FieldsV1",
        "fieldsV1": {
          "f:status": {
            "f:conditions": {
              "k:{\"type\":\"ContainersReady\"}": {
                ".": {},
                "f:lastProbeTime": {},
                "f:lastTransitionTime": {},
                "f:status": {},
                "f:type": {}
              },
              "k:{\"type\":\"Initialized\"}": {
                ".": {},
                "f:lastProbeTime": {},
                "f:lastTransitionTime": {},
                "f:status": {},
                "f:type": {}
              },
              "k:{\"type\":\"Ready\"}": {
                ".": {},
                "f:lastProbeTime": {},
                "f:lastTransitionTime": {},
                "f:status": {},
                "f:type": {}
              }
            },
            "f:containerStatuses": {},
            "f:hostIP": {},
            "f:phase": {},
            "f:podIP": {},
            "f:podIPs": {
              ".": {},
              "k:{\"ip\":\"172.17.0.3\"}": {
                ".": {},
                "f:ip": {}
              }
            },
            "f:startTime": {}
          }
        },
        "subresource": "status"
      }
    ]
  },
  "spec": {
    "volumes": [
      {
        "name": "kube-api-access-vl67x",
        "projected": {
          "sources": [
            {
              "serviceAccountToken": {
                "expirationSeconds": 3607,
                "path": "token"
              }
            },
            {
              "configMap": {
                "name": "kube-root-ca.crt",
                "items": [
                  {
                    "key": "ca.crt",
                    "path": "ca.crt"
                  }
                ]
              }
            },
            {
              "downwardAPI": {
                "items": [
                  {
                    "path": "namespace",
                    "fieldRef": {
                      "apiVersion": "v1",
                      "fieldPath": "metadata.namespace"
                    }
                  }
                ]
              }
            }
          ],
          "defaultMode": 420
        }
      }
    ],
    "containers": [
      {
        "name": "nginx",
        "image": "nginx:latest",
        "resources": {},
        "volumeMounts": [
          {
            "name": "kube-api-access-vl67x",
            "readOnly": true,
            "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount"
          }
        ],
        "terminationMessagePath": "/dev/termination-log",
        "terminationMessagePolicy": "File",
        "imagePullPolicy": "Always"
      }
    ],
    "restartPolicy": "Always",
    "terminationGracePeriodSeconds": 30,
    "dnsPolicy": "ClusterFirst",
    "serviceAccountName": "default",
    "serviceAccount": "default",
    "nodeName": "minikube",
    "securityContext": {},
    "schedulerName": "default-scheduler",
    "tolerations": [
      {
        "key": "node.kubernetes.io/not-ready",
        "operator": "Exists",
        "effect": "NoExecute",
        "tolerationSeconds": 300
      },
      {
        "key": "node.kubernetes.io/unreachable",
        "operator": "Exists",
        "effect": "NoExecute",
        "tolerationSeconds": 300
      }
    ],
    "priority": 0,
    "enableServiceLinks": true,
    "preemptionPolicy": "PreemptLowerPriority"
  },
  "status": {
    "phase": "Running",
    "conditions": [
      {
        "type": "Initialized",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:58:58Z"
      },
      {
        "type": "Ready",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:59:01Z"
      },
      {
        "type": "ContainersReady",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:59:01Z"
      },
      {
        "type": "PodScheduled",
        "status": "True",
        "lastProbeTime": null,
        "lastTransitionTime": "2022-12-13T12:58:58Z"
      }
    ],
    "hostIP": "192.168.49.2",
    "podIP": "172.17.0.3",
    "podIPs": [
      {
        "ip": "172.17.0.3"
      }
    ],
    "startTime": "2022-12-13T12:58:58Z",
    "containerStatuses": [
      {
        "name": "nginx",
        "state": {
          "running": {
            "startedAt": "2022-12-13T12:59:00Z"
          }
        },
        "lastState": {},
        "ready": true,
        "restartCount": 0,
        "image": "nginx:latest",
        "imageID": "docker-pullable://nginx@sha256:ab589a3c466e347b1c0573be23356676df90cd7ce2dbf6ec332a5f0a8b5e59db",
        "containerID": "docker://1c4c6718529aa94d2e488833dce100f556b3ae1057469a84906a8b543e7e8095",
        "started": true
      }
    ],
    "qosClass": "BestEffort"
  }
}
```

<br/>

If you want to run your app as a pod *inside* your kubernetes cluster, take a look at <a href="https://github.com/kubernetes/client-go/tree/master/examples/in-cluster-client-configuration">this</a> example.

