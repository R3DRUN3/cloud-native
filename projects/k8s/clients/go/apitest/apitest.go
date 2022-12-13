package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"path/filepath"
	"time"

	"k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

func main() {
	var kubeconfig *string
	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	flag.Parse()

	// use the current context in kubeconfig
	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		panic(err.Error())
	}

	// create the clientset
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}
	for {
		pods, err := clientset.CoreV1().Pods("").List(context.TODO(), metav1.ListOptions{})
		if err != nil {
			panic(err.Error())
		}
		fmt.Printf("\nThere are %d pods in the cluster\n", len(pods.Items))
		namespace := "client-go"
		podName := "nginx"
		podObject, err := clientset.CoreV1().Pods(namespace).Get(context.TODO(), podName, metav1.GetOptions{})
		if errors.IsNotFound(err) {
			fmt.Printf("Pod %s in namespace %s not found\n", podName, namespace)
		} else if statusError, isStatus := err.(*errors.StatusError); isStatus {
			fmt.Printf("Error getting pod %s in namespace %s: %v\n",
				podName, namespace, statusError.ErrStatus.Message)
		} else if err != nil {
			panic(err.Error())
		} else {
			fmt.Printf("Found pod %s in namespace %s\n\n", podName, namespace)
			podJSON, err := json.MarshalIndent(podObject, "", "  ")
			if err != nil {
				fmt.Printf("Error in converting Pod object to JSON:\n")
			}
			fmt.Printf("Pod Spec:\n %s\n", string(podJSON))
		}
		time.Sleep(100 * time.Second)
	}
}
