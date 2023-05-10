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

## LOCAL DOCKER REGISTRY
docker-registry-up: ## Spin up two local docker registries: staging and production
	@$(DOCKER) run -d -p 5000:5000 --restart=always --name registry-staging registry:2
	@$(DOCKER) run -d -p 5001:5000 --restart=always --name registry-prod registry:2
	@$(SLEEP) 6
	@$(CURL) -X GET http://localhost:5000/v2/_catalog
	@$(CURL) -X GET http://localhost:5001/v2/_catalog

docker-registry-down: ## Delete the local docker registry
	@$(DOCKER) container stop registry-staging
	@$(DOCKER) container rm -v registry-staging
	@$(DOCKER) container stop registry-prod
	@$(DOCKER) container rm -v registry-prod

## MINIKUBE
mini-up: ## Spin up a dev cluster with Minikube
	@$(MINIKUBE) start --profile tekton-cluster --memory 8192 --cpus 4
	@echo  "<installing tekton pipelines>"
	@$(KUBECTL) apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
	@echo  "<installing tekton dashboard>"
	@$(KUBECTL) apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml
	@$(SHELL) ./cluster-config/metrics.sh
	@echo  "<waiting for metrics server to be up and running>"
	@$(KUBECTL) wait deployment metrics-server -n kube-system --for condition=Available=True --timeout=70s
	@$(KUBECTL) get ns

mini-dashboard: ## Enable minikube web dashboard
	@$(MINIKUBE) dashboard --url

mini-down: ## Delete the Minikube dev cluster
	@$(MINIKUBE) stop --profile tekton-cluster
	@$(MINIKUBE) delete --profile tekton-cluster

tkn-install-tasks: ## Install required tasks from tekton hub
	@$(TKN) hub install task git-clone
	@$(TKN) hub install task check-make
	@$(TKN) hub install task markdown-lint
	@$(TKN) hub install task gitleaks
	@$(TKN) hub install task pylint
	@$(TKN) hub install task python-coverage
	@$(TKN) hub install task hadolint
	@$(TKN) hub install task kube-linter
	@$(TKN) hub install task helm-conftest
	@$(TKN) hub install task conftest
	@$(TKN) hub install task kaniko
	@$(TKN) hub install task trivy-scanner

tkn-run: ## Run tekton pipeline
	@$(KUBECTL) apply -f tekton/custom_skopeo_task.yaml
	@$(KUBECTL) apply -f tekton/pipeline.yaml
	@$(KUBECTL) create -f tekton/pipelinerun.yaml

docker-pull-and-run-from-local: ## Pull the image from local registry and runs it
	@$(DOCKER) pull localhost:5001/app:prod
	@$(DOCKER) run -it --rm -p 8887:8887 localhost:5001/app:prod