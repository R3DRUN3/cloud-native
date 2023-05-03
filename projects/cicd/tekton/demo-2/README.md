# TEKTON FIRST PIPELINE
This repo contains a working implementation of a `tekton` pipeline.
<br/>
We implement a tekton pipeline that clones a git repo and then builds and pushes the application OCI image to a local docker registry.
<br/>
Note, this is intended as a local development environment not suitable for production.


## Requirements
- Curl
- Make
- Docker
- Minikube
- Helm
- Kubectl
- Tekton CLI
- set docker <a href="https://docs.docker.com/registry/insecure/">insecure registry</a>


## Instruction
This repo contains a *Makefile* with all the required commands.

See make targets for instructions:
```console
make help

Usage:
  make <target>
  help             Display this help.
  docker-registry-up  Spin up a local docker registry
  docker-registry-down  Delete the local docker registry
  mini-up          Spin up a dev cluster with Minikube
  mini-dashboard   Enable minikube web dashboard
  mini-down        Delete the Minikube dev cluster
  tkn-install-tasks  Install required tasks from tekton hub
  tekton-run       Run tekton pipeline
  docker-pull-and-run-from-local  Pull the image from local registry and runs it
```

start a local minikube cluster (this will also install Tekton pipelines and dashboard on the cluster):
```console
make mini-up
```

start the local docker registry:
```console
make docker-registry-up
```
if the output of the previous command contains `{"repositories":[]}` you are good to go.

Install required tasks from tekton hub:
```console
make tkn-install-tasks
```
Create tekton `pipeline` and `pipelinerun` resources (this will automatically start the pipeline run):
```console
make tkn-run
```

If you want you can inspect the pipeline log from the dashboard, just run:
```console
 kubectl port-forward -n tekton-pipelines service/tekton-dashboard 9097:9097
```
and then open a browser to http://localhost:9097.

After a few seconds, our pipeline has terminated successfully:
<p float="left">
  <img src="images/pipeline.png" width="1300" />
</p>

We can prove this by pulling the builded image from our local registry and running it locally:
```console
make docker-pull-and-run-from-local
```

Now open the browser at http://localhost:8887 et voilà! 
<p float="left">
  <img src="images/app.png" width="1300" />
</p>

To clean all the resources simply run:
```console
make mini-down && make docker-registry-down
```
