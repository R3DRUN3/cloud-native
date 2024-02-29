# Dagger PoC
This repo contains examples and PoCs regarding the cloud native CI/CD tool <a href="https://dagger.io/">dagger</a>.  

## Prerequisites
- [Dagger CLI](https://docs.dagger.io/quickstart/729237/cli)
- [Docker](https://www.docker.com/get-started/)

## Examples
**Note**:  
The first time you run dagger on a system it takes some times becaus it needs to pull the [*dagger engine*](https://docs.dagger.io/developer-guide/overview/482011/architecture) image and start a new container from it.  
Also the first time you run a new function it takes more than subsequent times (cache).  

Run your first dagger function:  
```console
dagger -m github.com/shykes/daggerverse/hello@v0.1.2 call hello --greeting bonjour --name rabbit
```  
Output:  
```console
bonjour, rabbit!
```  



Now try calling the following function and see what happens:  
```console
dagger -m github.com/vikram-dagger/daggerverse/fileutils call tree --dir .
```  

Start an interactive terminal session with the container:  
```console
dagger call -m github.com/shykes/daggerverse/wolfi@v0.1.2 container --packages=cowsay with-exec --args cowsay,dagger stdout
```  

## Next steps
In order to go deeper see the [*official documentation*](https://docs.dagger.io/).  


