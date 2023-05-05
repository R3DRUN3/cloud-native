SHELL := /bin/bash
SLEEP=$(shell which sleep)
CURL=$(shell which curl)
DOCKER=$(shell which docker)
MINIKUBE=$(shell which minikube)
KUBECTL=$(shell which kubectl)
TKN=$(shell which tkn)
# KUBECONFIG ?= $(HOME)/.kube/config

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

## MINIKUBE
mini-up: ## Spin up a dev cluster with Minikube
	@$(MINIKUBE) start --profile tekton-cluster
	@echo  "<installing tekton pipelines>"
	@$(KUBECTL) apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	@echo  "<installing tekton dashboard>"
	@$(KUBECTL) apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml
	@echo  "<installing tekton triggers>"
	@$(KUBECTL) apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
	@$(KUBECTL) apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
	@$(SHELL) ./cluster-config/metrics.sh
	@echo  "<waiting for metrics server to be up and running>"
	@$(KUBECTL) wait deployment metrics-server -n kube-system --for condition=Available=True --timeout=60s
	@$(KUBECTL) get ns

mini-dashboard: ## Enable minikube web dashboard
	@$(MINIKUBE) dashboard --url

mini-down: ## Delete the Minikube dev cluster
	@$(MINIKUBE) stop --profile tekton-cluster
	@$(MINIKUBE) delete --profile tekton-cluster

tkn-run: ## Apply all needed tekton resources
	@$(KUBECTL) apply -f tekton/hello-world-task.yaml
	@$(KUBECTL) apply -f tekton/goodbye-world-task.yaml
	@$(KUBECTL) apply -f tekton/hello-goodbye-pipeline.yaml
	@$(KUBECTL) apply -f tekton/trigger-template.yaml
	@$(KUBECTL) apply -f tekton/trigger-binding.yaml
	@$(KUBECTL) apply -f tekton/rbac.yaml
	@$(KUBECTL) apply -f tekton/event-listener.yaml
