# Deployment of sample CNF (VPP ipforwarder) along with it's dependencies

## Overview

The initial steps of setting up a Target cluster are same as for the parent folder - so not duplicating them here.
Here is an outline of those skipped steps:
- Create the kind cluster
- Convert the kind cluster into managemnt cluster
- Create the target cluster
>   In this "phase apply docker" step, we have included a couple of postKubeadmCommands. 1 command is added to deploy "Calico CNI" on Kube Control Plane nodes. 2nd command is added to deploy "CNI plugin binaries" on the worker nodes. For details, plz see `dtc.yaml` in the patchset.
- Copy the kubeconfig file for target cluster
- Context swicth to Target Cluster (dtc-cluster)
- Push Capi components to Target cluster
- Context swicth to Management cluster
- Cluster Move from Management cluster to Target Cluster

After these steps, we have the actual 3 deployment steps for sample CNF:
- Deploy Helm-operator
- Deploy Multus Pods (VPP vSwitch)
- Deploy IPforwarder CNF

The airshipctl manifest changes related to deployment of the sample CNF (VPP ipforwarder), are available as a part of patchset [here](https://github.com/arun-n2020/airshipctl/commit/14c859fe1a20d410fe75a575a0d8fdffeb1323fa). The document also outlines the steps for the same.

The patchset has also been tested locally. For more information on Zuul check and local testing, visit [Zuul Check And Testing Scripts Locally](tests/README.md)

## Deployment Video Demonstration

A video demonstrating deployment of the sample CNF (VPP ipforwarder) and dependencies.

[![asciicast](https://asciinema.org/a/9jkWvepKHepKaXtKsv21iGsck.svg)](https://asciinema.org/a/9jkWvepKHepKaXtKsv21iGsck)

## Airshipctl Operations

**Deploy Helm-operator**

`$ airshipctl phase apply initinfra`

**Deploy Multus Pods (VPP vSwitch)**

`$ airshipctl phase apply multus`

**Deploy IPforwarder CNF**

`$ airshipctl phase apply ipforwarder`

## Airshipctl and Docker Test Site Manifests

`airshipctl phase apply docker` uses the manifests  available in `airshipctl/manifests/site/docker-test-site/target` to create a target workload cluster with 1 control plane and 1 machine deployment. The target cluster kubernetes version is v1.17.0

The spec for `kubeadmcontrolplane` in the target workload cluster manifest, deploys calico as the CNI solution using the postkubeadm command `kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/v3.12/manifests/calico.yaml`

The spec for `kubeadmconfigtemplate` in the target workload cluster manifest, deploys CNI plugins binaries in the Worker nodes, using the postkubeadm command `curl -fsSL https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz | tar -xz -C /opt/cni/bin/`

For more information, on understanding the manifests currently available for docker, refer to the manifest information available in [Reference](#reference)


## Common Pre-requisites

* Install [Docker](https://www.docker.com/)
* Install and setup [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Install [Kind](https://kind.sigs.k8s.io/)
* Install [Kustomize](https://kubernetes-sigs.github.io/kustomize/installation/binaries/)
* Install Airshipctl [Airshipctl](https://docs.airshipit.org/airshipctl/developers.html)

Also, check [Software Version Information](#software-version-information), [Special Instructions](#special-instructions) and [Virtual Machine Specification](#virtual-machine-specification)

## Install and configure a kubernetes cluster

## Reference

### Manifests for the Helm Operator (helm-controller), Multus CNI and Sample CNF (VPP-ipforwarder)

`ubuntu@ubuntu-VirtualBox:/tmp/airship/airshipctl/manifests$ tree function/helm-controller/`

```
function/helm-controller/
├── crd
│   ├── helmreleases.helm.fluxcd.io.yaml
│   └── kustomization.yaml
├── deployment.yaml
├── kustomization.yaml
├── namespace.yaml
└── rbac
    ├── kustomization.yaml
    ├── rolebinding.yaml
    ├── role.yaml
    └── serviceaccount.yaml

2 directories, 9 files
ubuntu@ubuntu-VirtualBox:/tmp/airship/airshipctl/manifests$ tree site/docker-test-site/target/multus/
site/docker-test-site/target/multus/
├── kustomization.yaml
└── multus-daemonset.yml

0 directories, 2 files
ubuntu@ubuntu-VirtualBox:/tmp/airship/airshipctl/manifests$ tree site/docker-test-site/target/ipforwarder/
site/docker-test-site/target/ipforwarder/
├── helmrelease.yaml
├── kustomization.yaml
└── namespace.yaml

0 directories, 3 files
```
### Docker Test Site Manifests

Docker Test Site contains shared and target directories, which have manifests for initializing the management and deploying the workload cluster respectively.

`$ tree manifests/site/docker-test-site`

```
manifests/site/docker-test-site
├── shared
│   └── clusterctl
│       ├── clusterctl.yaml
│       └── kustomization.yaml
└── target
    ├── docker
    │   ├── docker-target-cluster.yaml
    │   └── kustomization.yaml
    └── initinfra
        └── kustomization.yaml

```

The manifest for helm-controller is invoked in the kustomization of `initinfra` under `target`, thus it is deployed through `phase apply initinfra` step.

#### Target workload cluster

`airshipclt phase apply docker` uses the information in `manifests/site/docker-test-site/target/docker/docker-target-cluster.yaml`
to deploy a workload cluster `dtc` with one control plane and one machine deployment.

`$ cat docker-target-cluster.yaml`

```
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
kind: DockerCluster
metadata:
  name: dtc
  namespace: default
---
apiVersion: cluster.x-k8s.io/v1alpha3
kind: Cluster
metadata:
  name: dtc
  namespace: default
spec:
  clusterNetwork:
    pods:
      cidrBlocks:
      - 172.17.0.0/16
    serviceDomain: cluster.local
    services:
      cidrBlocks:
      - 10.0.0.0/24
  controlPlaneRef:
    apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
    kind: KubeadmControlPlane
    name: dtc-control-plane
  infrastructureRef:
    apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
    kind: DockerCluster
    name: dtc
---
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
kind: DockerMachineTemplate
metadata:
  name: dtc-control-plane
  namespace: default
spec:
  template:
    spec:
      extraMounts:
      - containerPath: /var/run/docker.sock
        hostPath: /var/run/docker.sock
---
apiVersion: controlplane.cluster.x-k8s.io/v1alpha3
kind: KubeadmControlPlane
metadata:
  name: dtc-control-plane
  namespace: default
spec:
  infrastructureTemplate:
    apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
    kind: DockerMachineTemplate
    name: dtc-control-plane
  kubeadmConfigSpec:
    clusterConfiguration:
      apiServer:
        certSANs:
        - localhost
        - 127.0.0.1
      controllerManager:
        extraArgs:
          enable-hostpath-provisioner: "true"
    files:
      - path: /calico.sh
        owner: root:root
        permissions: "0755"
        content: |
          #!/bin/sh -x
          su - root -c "sleep 10; kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/v3.12/manifests/calico.yaml"
    initConfiguration:
      nodeRegistration:
        criSocket: /var/run/containerd/containerd.sock
        kubeletExtraArgs:
          eviction-hard: nodefs.available<0%,nodefs.inodesFree<0%,imagefs.available<0%
    joinConfiguration:
      nodeRegistration:
        criSocket: /var/run/containerd/containerd.sock
        kubeletExtraArgs:
          eviction-hard: nodefs.available<0%,nodefs.inodesFree<0%,imagefs.available<0%
    postKubeadmCommands:
      - sh /calico.sh
  replicas: 1
  version: v1.17.0
---
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
kind: DockerMachineTemplate
metadata:
  name: dtc-md-0
  namespace: default
spec:
  template:
    spec:
      extraMounts:
      - containerPath: /var/run/docker.sock
        hostPath: /var/run/docker.sock
---
apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
kind: KubeadmConfigTemplate
metadata:
  name: dtc-md-0
  namespace: default
spec:
  template:
    spec:
      files:
      - path: /cniplugin.sh
        owner: root:root
        permissions: "0755"
        content: |
          #!/bin/sh -x
          su - root -c "curl -fsSL https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz | tar -xz -C /opt/cni/bin/" 
      joinConfiguration:
        nodeRegistration:
          criSocket: /var/run/containerd/containerd.sock
          kubeletExtraArgs:
            eviction-hard: nodefs.available<0%,nodefs.inodesFree<0%,imagefs.available<0%
      postKubeadmCommands:
       - sh /cniplugin.sh
---
apiVersion: cluster.x-k8s.io/v1alpha3
kind: MachineDeployment
metadata:
  name: dtc-md-0
  namespace: default
spec:
  clusterName: dtc
  replicas: 1
  selector:
    matchLabels: null
  template:
    metadata:
      labels:
        nodepool: pool1
    spec:
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
          kind: KubeadmConfigTemplate
          name: dtc-md-0
      clusterName: dtc
      infrastructureRef:
        permissions: "0755"
        content: |
          #!/bin/sh -x
          su - root -c "curl -fsSL https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz | tar -xz -C /opt/cni/bin/" 
      joinConfiguration:
        nodeRegistration:
          criSocket: /var/run/containerd/containerd.sock
          kubeletExtraArgs:
            eviction-hard: nodefs.available<0%,nodefs.inodesFree<0%,imagefs.available<0%
      postKubeadmCommands:
       - sh /cniplugin.sh
---
apiVersion: cluster.x-k8s.io/v1alpha3
kind: MachineDeployment
metadata:
  name: dtc-md-0
  namespace: default
spec:
  clusterName: dtc
  replicas: 1
  selector:
    matchLabels: null
  template:
    metadata:
      labels:
        nodepool: pool1
    spec:
      bootstrap:
        configRef:
          apiVersion: bootstrap.cluster.x-k8s.io/v1alpha3
          kind: KubeadmConfigTemplate
          name: dtc-md-0
      clusterName: dtc
      infrastructureRef:
        apiVersion: infrastructure.cluster.x-k8s.io/v1alpha3
        kind: DockerMachineTemplate
        name: dtc-md-0
      version: v1.17.0
---
apiVersion: cluster.x-k8s.io/v1alpha3
kind: MachineHealthCheck
metadata:
  name: dtc-mhc-0
  namespace: default
spec:
  clusterName: dtc
  maxUnhealthy: 100%
  selector:
    matchLabels:
      nodepool: pool1
  unhealthyConditions:
  - status: "True"
    timeout: 30s
    type: E2ENodeUnhealthy
```

#### Docker

$ docker version

```
Client: Docker Engine - Community
 Version:           19.03.12
 API version:       1.40
 Go version:        go1.13.10
 Git commit:        48a66213fe
 Built:             Mon Jun 22 15:45:36 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.12
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.10
  Git commit:       48a66213fe
  Built:            Mon Jun 22 15:44:07 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

#### Kind

$ kind version

```
kind v0.7.0 go1.13.6 linux/amd64
```

#### Kubectl

$ kubectl version

```
Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.4", GitCommit:"8d8aa39598534325ad77120c120a22b3a990b5ea", GitTreeState:"clean", BuildDate:"2020-03-12T21:03:42Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.0", GitCommit:"70132b0f130acc0bed193d9ba59dd186f0e634cf", GitTreeState:"clean", BuildDate:"2020-01-14T00:09:19Z", GoVersion:"go1.13.4", Compiler:"gc", Platform:"linux/amd64"}
```

#### Go

$ go version

```
go version go1.14.1 linux/amd64
```

#### Kustomize

$ kustomize version

```
{Version:kustomize/v3.8.0 GitCommit:6a50372dd5686df22750b0c729adaf369fbf193c BuildDate:2020-07-05T14:08:42Z GoOs:linux GoArch:amd64}
```

#### OS

$ cat /etc/os-release

```
NAME="Ubuntu"
VERSION="18.04.4 LTS (Bionic Beaver)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 18.04.4 LTS"
VERSION_ID="18.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=bionic
UBUNTU_CODENAME=bionic
```

#### Special Instructions

Swap was disabled on the VM using `sudo swapoff -a`

#### Virtual Machine Specification

All the instructions in the document were perfomed on a Oracle Virtual Box VM running Ubuntu 18.04.4 LTS (Bionic Beaver) with 10G of memory and 8 VCPUs

## See Also

### Zuul Check And Testing Scripts Locally

* [Zuul Check And Testing Scripts Locally](tests/README.md)
