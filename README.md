# qserv-operator

A qserv operator for Kubernetes based on [operator-framework](https://github.com/operator-framework). You may be familiar with Operators from the concept’s [introduction in 2016](https://coreos.com/blog/introducing-operators.html). An Operator is a method of packaging, deploying and managing a Kubernetes application.

*operator-sdk version: v0.13.0*

[![Build Status](https://travis-ci.org/lsst/qserv-operator.svg?branch=master)](https://travis-ci.org/lsst/qserv-operator)
[![build & test](https://github.com/lsst/qserv-operator/workflows/build%20&%20test/badge.svg)](https://github.com/lsst/qserv-operator/actions?query=branch%3A+master)

## Deploy qserv

### Quick start for Ubuntu LTS

```
sudo apt-get update
sudo apt-get install curl docker.io git vim
# then add current user to docker group and restart gnome session
sudo usermod -a -G docker $(id -nu)

WORKDIR="$HOME/src"
mkdir -p "$WORKDIR"

# Create single node k8s cluster with kind
cd "$WORKDIR"
git clone --depth 1 -b "v0.6.0" --single-branch https://github.com/k8s-school/kind-travis-ci
cd kind-travis-ci
./kind/k8s-create.sh -s

cd "$WORKDIR"
git clone  https://github.com/lsst/qserv-operator
cd qserv-operator
cp env.example.sh env.sh
./deploy.sh
./wait-operator-ready.sh
kubectl apply -k base
./wait-qserv-ready.sh
./run-integration-tests.sh
```

### Prerequisites

#### For a local workstation

- Ubuntu LTS is recommended
- 8 cores, 16 GB RAM, 30GB for the partition hosting docker entities (images, volumes, containers, etc). Use `df` command as below to find its size.
```bash
sudo df –sh /var/lib/docker # or /var/snap/docker/common/var-lib-docker/
```
- Internet access without proxy
- `sudo` access
- Install dependencies below:
```bash
sudo apt-get install curl docker.io git vim
```
- Add current user to docker group and restart gnome session
```bash
sudo usermod -a -G docker <USER>
```
- Depending on your linux distribution version, you might have to upgrade to docker-ce: https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1
- Install Kubernetes locally using  [kind-travis-ci], a one-liner to install Kubernetes, based on [kind].

#### Generic to all setups

- Access to a Kubernetes v1.14.2+ cluster via a valid `KUBECONFIG` file.
- Dynamic volume provisionning need to be available on the Kubernetes cluster (for example [kind] for or GKE).

[kind]:https://kind.sigs.k8s.io/
[kind-travis-ci]:https://github.com/k8s-school/kind-travis-ci

### Deploy qserv-operator

Command below deploy `qserv-operator`

```sh
# Deploy qserv-operator
git clone https://github.com/lsst/qserv-operator.git
cd qserv-operator
# Edit env.sh to set the namespace where qserv-operator will be deployed (TODO: replace with cmd-line option)
cp env.example.sh env.sh
./deploy.sh
```

### Deploy a qserv instance with default settings

This deployment is recommended for development purpose, or continuous integration.
Qserv install customization is handled with [Kustomize](https://github.com/kubernetes-sigs/kustomize), which is a template engine allowing to customize kubernetes Yaml files. `Kustomize` is integrated with `kubectl` (`-k` option).

```sh
# Install a qserv instance with default settings in default namespace
kubectl apply -k ./base --namespace='default'
```

### Undeploy a qserv instance

First list all Qserv instances running in a given namespace
```sh
kubectl get qserv -n "<namespace>"
```

It will output something like:

```
NAME            AGE
example-qserv   59m
```

Then delete this Qserv instance

```sh
kubectl delete qserv example-qserv -n "<namespace>"
```

To delete all Qserv instances inside a namespace:

```sh
kubectl delete qserv --all -n "<namespace>"
```

All qserv storage will remain untouch by this operation.

### Deploy a qserv instance with custom settings

Example are available, see below:

```sh
# Install a qserv instance with custom settings
kubectl apply -k overlays/ncsa_dev/ --namespace='qserv-dev'

# Install a qserv instance with custom settings
kubectl apply -k overlays/ncsa_prod/ --namespace='qserv-prod'
```

In order to create a customized Qserv instance, create a `Kustomize` overlay using instruction below:
```sh
cp -r overlays/local/ overlays/my-qserv/
```

Then add custom setting, for example container image versions, by editing `overlays/my-qserv/qserv.yaml`:

```
apiVersion: qserv.lsst.org/v1alpha1
kind: Qserv
metadata:
  name: qserv
spec:
  storageclass: "standard"
  storagecapacity: "1Gi"
  # Used by czar and worker pods
  worker:
    replicas: 3
    image: "qserv/qserv:ad8405c"
  replication:
      image: "qserv/replica:tools-w.2018.16-1171-gcbabd53"
      dbimage: "mariadb:10.2.16"
  xrootd:
    image: "qserv/qserv:ad8405c"
```
It is possible to use any recent Qserv image generated by [Qserv Travis-CI](https://travis-ci.org/lsst/qserv/)

And finally create customized Qserv instance:

```sh
kubectl apply -k overlays/my-qserv/ --namespace='<namespace>'
```


### Connect to the qserv instance

```sh
./run-integration-tests.sh
```

## Build qserv-operator

### Prerequisites

- [git][git_tool]
- [go][go_tool] version v1.12+.
- [docker][docker_tool] version 17.03+.
- [kubectl][kubectl_tool] version v1.11.3+.
- Access to a Kubernetes v1.14.2+ cluster.


[git_tool]:https://git-scm.com/downloads
[go_tool]:https://golang.org/dl/
[docker_tool]:https://docs.docker.com/install/
[kubectl_tool]:https://kubernetes.io/docs/tasks/tools/install-kubectl/

### Build

```sh
git clone https://github.com/lsst/qserv-operator.git
cd qserv-operator
./build-all.sh
```

### Test qserv-operator

```sh
./deploy.sh
./run-multinode-tests.sh
```
