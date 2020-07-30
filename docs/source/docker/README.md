# Airshipctl and Cluster API Docker Integration

- [Airshipctl and Cluster API Docker Integration](#airshipctl-and-cluster-api-docker-integration)
  - [Overview](#overview)
  - [Patchset Usage - Video Demonstration](#patchset-usage---video-demonstration)
  - [Airshipctl Operations](#airshipctl-operations)
  - [Airshipctl and Docker Test Site Manifests](#airshipctl-and-docker-test-site-manifests)
  - [Common Pre-requisites](#common-pre-requisites)
  - [Install and configure a kubernetes cluster](#install-and-configure-a-kubernetes-cluster)
  - [Create airshipctl configuration files](#create-airshipctl-configuration-files)
  - [Pull documents from airshipctl repository](#pull-documents-from-airshipctl-repository)
  - [Use the latest patchset for docker](#use-the-latest-patchset-for-docker)
  - [Docker Overrides - Generate Metadata for infrastructure  provider docker](#docker-overrides---generate-metadata-for-infrastructure-provider-docker)
  - [Initialize the management cluster](#initialize-the-management-cluster)
  - [Create your first workload cluster](#create-your-first-workload-cluster)
  - [Reference](#reference)
    - [Cluster Api Docker Provider Manifests](#cluster-api-docker-provider-manifests)
    - [Local Overrides For Docker](#local-overrides-for-docker)
    - [CAPD Manager Image Version](#capd-manager-image-version)
    - [Docker Test Site Manifests](#docker-test-site-manifests)
      - [Management cluster](#management-cluster)
      - [Target workload cluster](#target-workload-cluster)
    - [Airshipctl Configuration File](#airshipctl-configuration-file)
    - [Software Version Information](#software-version-information)
      - [Docker](#docker)
      - [Kind](#kind)
      - [Kubectl](#kubectl)
      - [Go](#go)
      - [Kustomize](#kustomize)
      - [OS](#os)
      - [Special Instructions](#special-instructions)
      - [Virtual Machine Specification](#virtual-machine-specification)
  - [Future Improvements](#future-improvements)
    - [Remove usage of docker overrides](#remove-usage-of-docker-overrides)
  - [See Also](#see-also)
    - [Zuul Check And Testing Scripts Locally](#zuul-check-and-testing-scripts-locally)

## Overview

Airshipctl and cluster api docker integration facilitates usage of `airshipctl` to create cluster api management and workload clusters using `docker as infrastructure provider`. This document provides instructions on the usage of airshipctl, to perform the following operations using docker as infrastructure provider:

- Initialize the management cluster with cluster api, and cluster api docker provider components
- Create a target workload cluster, and deploy calico as the CNI solution on the target workload cluster

Airshipctl uses the information available in the manifests to initialize the management cluster, deploy the target workload cluster, and deploy calico as the CNI solution on the target workload cluster.

Airshipctl and cluster api docker integration is available as a part of patchset - `https://review.opendev.org/#/c/737871/`. The document also provides information on usage of the patchset.

The patchset has also been tested locally. For more information on Zuul check and local testing, visit [Zuul Check And Testing Scripts Locally](tests/README.md)

## Patchset Usage - Video Demonstration

A video demonstrating usage of the patchset `https://review.opendev.org/#/c/737871/`

[![asciicast](https://asciinema.org/a/5FNDbWYlJpm1swwnDLZCTRfpk.svg)](https://asciinema.org/a/5FNDbWYlJpm1swwnDLZCTRfpk)

## Airshipctl Operations

**Initialize the management cluster with cluster api and docker provider components**

`$ airshipctl cluster init`

**Create a target workload cluster, and deploy calico as CNI solution on the target workload cluster**

`$ airshipctl phase apply docker`

## Airshipctl and Docker Test Site Manifests

`airshipctl cluster init` utilizes the manifests currently available in site `airshipctl/manifests/site/docker-test-site/shared` to initialize the management cluster with the following provider components and version.

| provider component name | provider component type | provider component version |
| ----------------------- | ----------------------- | -------------------------- |
| docker                  | infrastructure-provider | v0.3.0                     |
| cluster-api             | core-provider           | v0.3.3                     |
| kubeadm                 | control-plane-provider  | v0.3.3                     |
| kubeadm                 | bootstrap-provider      | v0.3.3                     |

 `airshipctl phase apply docker` uses the manifests  available in `airshipctl/manifests/site/docker-test-site/target` to create a target workload cluster with 1 control plane and 1 machine deployment. The target cluster kubernetes version is v1.17.0

The spec for `kubeadmcontrolplane` in the target workload cluster manifest, deploys calico as the CNI solution using the postkubeadm command `kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/v3.12/manifests/calico.yaml`

For more information, on understanding the manifests currently available for docker, refer to the manifest information available in [Reference](#reference)


## Common Pre-requisites

* Install [Docker](https://www.docker.com/)
* Install and setup [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Install [Kind](https://kind.sigs.k8s.io/)
* Install [Kustomize](https://kubernetes-sigs.github.io/kustomize/installation/binaries/)
* Install Airshipctl [Airshipctl](https://docs.airshipit.org/airshipctl/developers.html)

Also, check [Software Version Information](#software-version-information), [Special Instructions](#special-instructions) and [Virtual Machine Specification](#virtual-machine-specification)

## Install and configure a kubernetes cluster

Kind will be used to setup a kubernetes cluster. The kubernetes cluster will be later transformed into a management cluster using airshipctl. The kind kubernetes cluster will be initialized with cluster API and Cluster API docker provider components.

Run the following command to create a kind configuration file, that  would mount the docker.sock file from the host operating system into the kind cluster. This is required by the management cluster to create machines as docker containers.

$ vim kind-cluster-with-extramounts.yaml

```
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: /var/run/docker.sock
        containerPath: /var/run/docker.sock

```

Save and exit.

$ kind create cluster --config kind-cluster-with-extramounts.yaml --name capi-docker

```
Creating cluster "capi-docker" ...
 ✓ Ensuring node image (kindest/node:v1.17.0) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-capi-docker"
You can now use your cluster with:

kubectl cluster-info --context kind-capi-docker

```
Check if all the pods are up.

$ kubectl get pods -A

```
NAMESPACE            NAME                                                READY   STATUS    RESTARTS   AGE
kube-system          coredns-6955765f44-76mqd                            1/1     Running   0          96s
kube-system          coredns-6955765f44-jd62f                            1/1     Running   0          96s
kube-system          etcd-capi-docker-control-plane                      1/1     Running   0          108s
kube-system          kindnet-8q2jz                                       1/1     Running   0          96s
kube-system          kube-apiserver-capi-docker-control-plane            1/1     Running   0          108s
kube-system          kube-controller-manager-capi-docker-control-plane   1/1     Running   0          108s
kube-system          kube-proxy-wp4lz                                    1/1     Running   0          96s
kube-system          kube-scheduler-capi-docker-control-plane            1/1     Running   0          108s
local-path-storage   local-path-provisioner-7745554f7f-wpfrv             1/1     Running   0          96s
```

## Create airshipctl configuration files

$ mkdir ~/.airship

$ cp ~/.kube/config ~/.airship/kubeconfig

$ touch ~/.airship/config

$ airshipctl config init

$ airshipctl config get-context

```
Context: kind-capi-docker
contextKubeconf: kind-capi-docker_target

LocationOfOrigin: /home/rishabh/.airship/kubeconfig
cluster: kind-capi-docker_target
user: kind-capi-docker
```

Add the `docker-manifest` section (starts from docker_manifest: ) to manifests in `~/.airship/config`

$ vim ~/.airship/config

```
manifests:
  docker_manifest:
    primaryRepositoryName: primary
    repositories:
      primary:
        checkout:
          branch: master
          commitHash: ""
          force: false
          tag: ""
        url: https://review.opendev.org/airship/airshipctl
    subPath: airshipctl/manifests/site/docker-test-site
    targetPath: /tmp/airship
```
save and exit

Configure the kind-capi-docker context to use docker_manifest as manifest.

$ airshipctl config set-context kind-capi-docker --manifest docker_manifest

```
Context "kind-capi-docker" modified.
```

$ airshipctl config get-context

```
Context: kind-capi-docker
contextKubeconf: kind-capi-docker_target
manifest: docker_manifest

LocationOfOrigin: /home/rishabh/.airship/kubeconfig
cluster: kind-capi-docker_target
user: kind-capi-docker
```

## Pull documents from airshipctl repository

$ airshipctl document pull

This step will clone the airshipctl repository in `/tmp/airship`.
This is because the targetPath for `docker_manifest` in airship configuration file is  `/tmp/airship`

## Use the latest patchset for docker

Go to `https://review.opendev.org/#/c/737871`

Navigate to Download -> Archive -> Tar

Right click on `tar`, and copy the link address

![Patch Set Usage](https://i.imgur.com/C7xNQCM.jpg)

Run the following commands to download and extract the latest patchset

`$ export PATCH_URL=<paste_link_address_here>`

`$ wget ${PATCH_URL} -O /tmp/airship/airshipctl/manifests.tar`

`$ cd /tmp/airship/airshipctl && tar xvf manifests.tar`

## Docker Overrides - Generate Metadata for infrastructure  provider docker

The script reads from the local repository `airshipctl/manifests/function/capd/v0.3.0` of the docker provider and builds the providers’ assets, and places them in a local override directory located under `$HOME/.cluster-api/overrides/`

For more information on docker overrides, refer to the [Docker Overrides](#local-overrides-for-docker) in reference section of the document.

To execute the docker overrides hack, go to the root directory of the docker provider

$ cd /tmp/airship/airshipctl/manifests/function/capd

Run docker-overrides.py

$ ./docker-overrides.py

```
airshipctl local overrides generated from the local repository for docker provider airshipctl/manifests/function/capd/v0.3.0
in order to use them, please run:

airshipctl cluster init --debug
```

This would create the metadata required in `$HOME/.cluster-api/overrides/`

`$ tree  ~/.cluster-api`

```
~/.cluster-api
└── overrides
    └── infrastructure-docker
        └── v0.3.0
            ├── infrastructure-components.yaml
            └── metadata.yaml

3 directories, 2 files
```

## Initialize the management cluster

$ airshipctl cluster init --debug

```
[airshipctl] 2020/07/10 01:49:00 Starting cluster-api initiation
Installing the clusterctl inventory CRD
Creating CustomResourceDefinition="providers.clusterctl.cluster.x-k8s.io"
Fetching providers
[airshipctl] 2020/07/10 01:49:00 Creating arishipctl repository implementation interface for provider cluster-api of type CoreProvider
[airshipctl] 2020/07/10 01:49:00 Setting up airshipctl provider Components client
Provider type: CoreProvider, name: cluster-api
[airshipctl] 2020/07/10 01:49:00 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: CoreProvider, name: cluster-api
Fetching File="components.yaml" Provider="cluster-api" Version="v0.3.3"
[airshipctl] 2020/07/10 01:49:00 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/capi/v0.3.3
[airshipctl] 2020/07/10 01:49:00 Creating arishipctl repository implementation interface for provider kubeadm of type BootstrapProvider
[airshipctl] 2020/07/10 01:49:00 Setting up airshipctl provider Components client
Provider type: BootstrapProvider, name: kubeadm
[airshipctl] 2020/07/10 01:49:00 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: BootstrapProvider, name: kubeadm
Fetching File="components.yaml" Provider="bootstrap-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/10 01:49:00 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/cabpk/v0.3.3
[airshipctl] 2020/07/10 01:49:01 Creating arishipctl repository implementation interface for provider kubeadm of type ControlPlaneProvider
[airshipctl] 2020/07/10 01:49:01 Setting up airshipctl provider Components client
Provider type: ControlPlaneProvider, name: kubeadm
[airshipctl] 2020/07/10 01:49:01 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: ControlPlaneProvider, name: kubeadm
Fetching File="components.yaml" Provider="control-plane-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/10 01:49:01 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/cacpk/v0.3.3
[airshipctl] 2020/07/10 01:49:01 Creating arishipctl repository implementation interface for provider docker of type InfrastructureProvider
[airshipctl] 2020/07/10 01:49:01 Setting up airshipctl provider Components client
Provider type: InfrastructureProvider, name: docker
[airshipctl] 2020/07/10 01:49:01 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: InfrastructureProvider, name: docker
Fetching File="components.yaml" Provider="infrastructure-docker" Version="v0.3.0"
[airshipctl] 2020/07/10 01:49:01 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/capd/v0.3.0
[airshipctl] 2020/07/10 01:49:01 Creating arishipctl repository implementation interface for provider cluster-api of type CoreProvider
Fetching File="metadata.yaml" Provider="cluster-api" Version="v0.3.3"
[airshipctl] 2020/07/10 01:49:01 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/capi/v0.3.3
[airshipctl] 2020/07/10 01:49:01 Creating arishipctl repository implementation interface for provider kubeadm of type BootstrapProvider
Fetching File="metadata.yaml" Provider="bootstrap-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/10 01:49:01 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/cabpk/v0.3.3
[airshipctl] 2020/07/10 01:49:01 Creating arishipctl repository implementation interface for provider kubeadm of type ControlPlaneProvider
Fetching File="metadata.yaml" Provider="control-plane-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/10 01:49:01 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/cacpk/v0.3.3
[airshipctl] 2020/07/10 01:49:01 Creating arishipctl repository implementation interface for provider docker of type InfrastructureProvider
Using Override="metadata.yaml" Provider="infrastructure-docker" Version="v0.3.0"
Installing cert-manager
Creating Namespace="cert-manager"
Creating CustomResourceDefinition="challenges.acme.cert-manager.io"
Creating CustomResourceDefinition="orders.acme.cert-manager.io"
Creating CustomResourceDefinition="certificaterequests.cert-manager.io"
Creating CustomResourceDefinition="certificates.cert-manager.io"
Creating CustomResourceDefinition="clusterissuers.cert-manager.io"
Creating CustomResourceDefinition="issuers.cert-manager.io"
Creating ServiceAccount="cert-manager-cainjector" Namespace="cert-manager"
Creating ServiceAccount="cert-manager" Namespace="cert-manager"
Creating ServiceAccount="cert-manager-webhook" Namespace="cert-manager"
Creating ClusterRole="cert-manager-cainjector"
Creating ClusterRoleBinding="cert-manager-cainjector"
Creating Role="cert-manager-cainjector:leaderelection" Namespace="kube-system"
Creating RoleBinding="cert-manager-cainjector:leaderelection" Namespace="kube-system"
Creating ClusterRoleBinding="cert-manager-webhook:auth-delegator"
Creating RoleBinding="cert-manager-webhook:webhook-authentication-reader" Namespace="kube-system"
Creating ClusterRole="cert-manager-webhook:webhook-requester"
Creating Role="cert-manager:leaderelection" Namespace="kube-system"
Creating RoleBinding="cert-manager:leaderelection" Namespace="kube-system"
Creating ClusterRole="cert-manager-controller-issuers"
Creating ClusterRole="cert-manager-controller-clusterissuers"
Creating ClusterRole="cert-manager-controller-certificates"
Creating ClusterRole="cert-manager-controller-orders"
Creating ClusterRole="cert-manager-controller-challenges"
Creating ClusterRole="cert-manager-controller-ingress-shim"
Creating ClusterRoleBinding="cert-manager-controller-issuers"
Creating ClusterRoleBinding="cert-manager-controller-clusterissuers"
Creating ClusterRoleBinding="cert-manager-controller-certificates"
Creating ClusterRoleBinding="cert-manager-controller-orders"
Creating ClusterRoleBinding="cert-manager-controller-challenges"
Creating ClusterRoleBinding="cert-manager-controller-ingress-shim"
Creating ClusterRole="cert-manager-view"
Creating ClusterRole="cert-manager-edit"
Creating Service="cert-manager" Namespace="cert-manager"
Creating Service="cert-manager-webhook" Namespace="cert-manager"
Creating Deployment="cert-manager-cainjector" Namespace="cert-manager"
Creating Deployment="cert-manager" Namespace="cert-manager"
Creating Deployment="cert-manager-webhook" Namespace="cert-manager"
Creating APIService="v1beta1.webhook.cert-manager.io"
Creating MutatingWebhookConfiguration="cert-manager-webhook"
Creating ValidatingWebhookConfiguration="cert-manager-webhook"
Waiting for cert-manager to be available...
Installing Provider="cluster-api" Version="v0.3.3" TargetNamespace="capi-system"
Creating shared objects Provider="cluster-api" Version="v0.3.3"
Creating Namespace="capi-webhook-system"
Creating CustomResourceDefinition="clusters.cluster.x-k8s.io"
Creating CustomResourceDefinition="machinedeployments.cluster.x-k8s.io"
Creating CustomResourceDefinition="machinehealthchecks.cluster.x-k8s.io"
Creating CustomResourceDefinition="machinepools.exp.cluster.x-k8s.io"
Creating CustomResourceDefinition="machines.cluster.x-k8s.io"
Creating CustomResourceDefinition="machinesets.cluster.x-k8s.io"
Creating MutatingWebhookConfiguration="capi-mutating-webhook-configuration"
Creating Service="capi-webhook-service" Namespace="capi-webhook-system"
Creating Deployment="capi-controller-manager" Namespace="capi-webhook-system"
Creating Certificate="capi-serving-cert" Namespace="capi-webhook-system"
Creating Issuer="capi-selfsigned-issuer" Namespace="capi-webhook-system"
Creating ValidatingWebhookConfiguration="capi-validating-webhook-configuration"
Creating instance objects Provider="cluster-api" Version="v0.3.3" TargetNamespace="capi-system"
Creating Namespace="capi-system"
Creating Role="capi-leader-election-role" Namespace="capi-system"
Creating ClusterRole="capi-system-capi-aggregated-manager-role"
Creating ClusterRole="capi-system-capi-manager-role"
Creating ClusterRole="capi-system-capi-proxy-role"
Creating RoleBinding="capi-leader-election-rolebinding" Namespace="capi-system"
Creating ClusterRoleBinding="capi-system-capi-manager-rolebinding"
Creating ClusterRoleBinding="capi-system-capi-proxy-rolebinding"
Creating Service="capi-controller-manager-metrics-service" Namespace="capi-system"
Creating Deployment="capi-controller-manager" Namespace="capi-system"
Creating inventory entry Provider="cluster-api" Version="v0.3.3" TargetNamespace="capi-system"
Installing Provider="bootstrap-kubeadm" Version="v0.3.3" TargetNamespace="capi-kubeadm-bootstrap-system"
Creating shared objects Provider="bootstrap-kubeadm" Version="v0.3.3"
Creating CustomResourceDefinition="kubeadmconfigs.bootstrap.cluster.x-k8s.io"
Creating CustomResourceDefinition="kubeadmconfigtemplates.bootstrap.cluster.x-k8s.io"
Creating Service="capi-kubeadm-bootstrap-webhook-service" Namespace="capi-webhook-system"
Creating Deployment="capi-kubeadm-bootstrap-controller-manager" Namespace="capi-webhook-system"
Creating Certificate="capi-kubeadm-bootstrap-serving-cert" Namespace="capi-webhook-system"
Creating Issuer="capi-kubeadm-bootstrap-selfsigned-issuer" Namespace="capi-webhook-system"
Creating instance objects Provider="bootstrap-kubeadm" Version="v0.3.3" TargetNamespace="capi-kubeadm-bootstrap-system"
Creating Namespace="capi-kubeadm-bootstrap-system"
Creating Role="capi-kubeadm-bootstrap-leader-election-role" Namespace="capi-kubeadm-bootstrap-system"
Creating ClusterRole="capi-kubeadm-bootstrap-system-capi-kubeadm-bootstrap-manager-role"
Creating ClusterRole="capi-kubeadm-bootstrap-system-capi-kubeadm-bootstrap-proxy-role"
Creating RoleBinding="capi-kubeadm-bootstrap-leader-election-rolebinding" Namespace="capi-kubeadm-bootstrap-system"
Creating ClusterRoleBinding="capi-kubeadm-bootstrap-system-capi-kubeadm-bootstrap-manager-rolebinding"
Creating ClusterRoleBinding="capi-kubeadm-bootstrap-system-capi-kubeadm-bootstrap-proxy-rolebinding"
Creating Service="capi-kubeadm-bootstrap-controller-manager-metrics-service" Namespace="capi-kubeadm-bootstrap-system"
Creating Deployment="capi-kubeadm-bootstrap-controller-manager" Namespace="capi-kubeadm-bootstrap-system"
Creating inventory entry Provider="bootstrap-kubeadm" Version="v0.3.3" TargetNamespace="capi-kubeadm-bootstrap-system"
Installing Provider="control-plane-kubeadm" Version="v0.3.3" TargetNamespace="capi-kubeadm-control-plane-system"
Creating shared objects Provider="control-plane-kubeadm" Version="v0.3.3"
Creating CustomResourceDefinition="kubeadmcontrolplanes.controlplane.cluster.x-k8s.io"
Creating MutatingWebhookConfiguration="capi-kubeadm-control-plane-mutating-webhook-configuration"
Creating Service="capi-kubeadm-control-plane-webhook-service" Namespace="capi-webhook-system"
Creating Deployment="capi-kubeadm-control-plane-controller-manager" Namespace="capi-webhook-system"
Creating Certificate="capi-kubeadm-control-plane-serving-cert" Namespace="capi-webhook-system"
Creating Issuer="capi-kubeadm-control-plane-selfsigned-issuer" Namespace="capi-webhook-system"
Creating ValidatingWebhookConfiguration="capi-kubeadm-control-plane-validating-webhook-configuration"
Creating instance objects Provider="control-plane-kubeadm" Version="v0.3.3" TargetNamespace="capi-kubeadm-control-plane-system"
Creating Namespace="capi-kubeadm-control-plane-system"
Creating Role="capi-kubeadm-control-plane-leader-election-role" Namespace="capi-kubeadm-control-plane-system"
Creating Role="capi-kubeadm-control-plane-manager-role" Namespace="capi-kubeadm-control-plane-system"
Creating ClusterRole="capi-kubeadm-control-plane-system-capi-kubeadm-control-plane-manager-role"
Creating ClusterRole="capi-kubeadm-control-plane-system-capi-kubeadm-control-plane-proxy-role"
Creating RoleBinding="capi-kubeadm-control-plane-leader-election-rolebinding" Namespace="capi-kubeadm-control-plane-system"
Creating ClusterRoleBinding="capi-kubeadm-control-plane-system-capi-kubeadm-control-plane-manager-rolebinding"
Creating ClusterRoleBinding="capi-kubeadm-control-plane-system-capi-kubeadm-control-plane-proxy-rolebinding"
Creating Service="capi-kubeadm-control-plane-controller-manager-metrics-service" Namespace="capi-kubeadm-control-plane-system"
Creating Deployment="capi-kubeadm-control-plane-controller-manager" Namespace="capi-kubeadm-control-plane-system"
Creating inventory entry Provider="control-plane-kubeadm" Version="v0.3.3" TargetNamespace="capi-kubeadm-control-plane-system"
Installing Provider="infrastructure-docker" Version="v0.3.0" TargetNamespace="capd-system"
Creating shared objects Provider="infrastructure-docker" Version="v0.3.0"
Creating CustomResourceDefinition="dockerclusters.infrastructure.cluster.x-k8s.io"
Creating CustomResourceDefinition="dockermachines.infrastructure.cluster.x-k8s.io"
Creating CustomResourceDefinition="dockermachinetemplates.infrastructure.cluster.x-k8s.io"
Creating ValidatingWebhookConfiguration="capd-validating-webhook-configuration"
Creating instance objects Provider="infrastructure-docker" Version="v0.3.0" TargetNamespace="capd-system"
Creating Namespace="capd-system"
Creating Role="capd-leader-election-role" Namespace="capd-system"
Creating ClusterRole="capd-system-capd-manager-role"
Creating ClusterRole="capd-system-capd-proxy-role"
Creating RoleBinding="capd-leader-election-rolebinding" Namespace="capd-system"
Creating ClusterRoleBinding="capd-system-capd-manager-rolebinding"
Creating ClusterRoleBinding="capd-system-capd-proxy-rolebinding"
Creating Service="capd-controller-manager-metrics-service" Namespace="capd-system"
Creating Service="capd-webhook-service" Namespace="capd-system"
Creating Deployment="capd-controller-manager" Namespace="capd-system"
Creating Certificate="capd-serving-cert" Namespace="capd-system"
Creating Issuer="capd-selfsigned-issuer" Namespace="capd-system"
Creating inventory entry Provider="infrastructure-docker" Version="v0.3.0" TargetNamespace="capd-system"
```

Wait for all the pods to be up.

$ kubectl get pods -A

```
NAMESPACE                           NAME                                                             READY   STATUS    RESTARTS   AGE
capd-system                         capd-controller-manager-75f5d546d7-xz4vm                         2/2     Running   0          82s
capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-5bb9bfdc46-n7dbk       2/2     Running   0          88s
capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-77466c7666-8fbw6   2/2     Running   0          85s
capi-system                         capi-controller-manager-5798474d9f-jzkrk                         2/2     Running   0          90s
capi-webhook-system                 capi-controller-manager-5d64dd9dfb-cqndz                         2/2     Running   0          91s
capi-webhook-system                 capi-kubeadm-bootstrap-controller-manager-7c78fff45-h9rkl        2/2     Running   0          89s
capi-webhook-system                 capi-kubeadm-control-plane-controller-manager-58465bb88f-7w22w   2/2     Running   0          87s
cert-manager                        cert-manager-69b4f77ffc-wtxzz                                    1/1     Running   0          2m1s
cert-manager                        cert-manager-cainjector-576978ffc8-5lchc                         1/1     Running   0          2m1s
cert-manager                        cert-manager-webhook-c67fbc858-tdzgt                             1/1     Running   2          2m1s
kube-system                         coredns-6955765f44-76mqd                                         1/1     Running   0          12m
kube-system                         coredns-6955765f44-jd62f                                         1/1     Running   0          12m
kube-system                         etcd-capi-docker-control-plane                                   1/1     Running   0          12m
kube-system                         kindnet-8q2jz                                                    1/1     Running   0          12m
kube-system                         kube-apiserver-capi-docker-control-plane                         1/1     Running   0          12m
kube-system                         kube-controller-manager-capi-docker-control-plane                1/1     Running   0          12m
kube-system                         kube-proxy-wp4lz                                                 1/1     Running   0          12m
kube-system                         kube-scheduler-capi-docker-control-plane                         1/1     Running   0          12m
local-path-storage                  local-path-provisioner-7745554f7f-wpfrv                          1/1     Running   0          12m
```

Now, the management cluster is initialized with cluster api and cluster api docker provider components.

$ kubectl get providers -A

```
NAMESPACE                           NAME                    TYPE   PROVIDER                 VERSION   WATCH NAMESPACE
capd-system                         infrastructure-docker          InfrastructureProvider   v0.3.0
capi-kubeadm-bootstrap-system       bootstrap-kubeadm              BootstrapProvider        v0.3.3
capi-kubeadm-control-plane-system   control-plane-kubeadm          ControlPlaneProvider     v0.3.3
capi-system                         cluster-api                    CoreProvider             v0.3.3
```

$ docker ps

```
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                                  NAMES
b9690cecdcf2        kindest/node:v1.17.0           "/usr/local/bin/entr…"   14 minutes ago      Up 14 minutes       127.0.0.1:32773->6443/tcp              capi-docker-control-plane
```


## Create your first workload cluster

`airshipctl phase apply docker` uses the manifests  available in `airshipctl/manifests/site/docker-test-site/target` to
create a workload cluster.  In the current patchset, manifests are configured to deploy 1 machine deployment and 1 control plane. The target cluster kubernetes version is v1.17.0

The spec for `kubeadmcontrolplane` in the target workload cluster manifest, deploys calico as the CNI solution using the postkubeadm command `kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f https://docs.projectcalico.org/v3.12/manifests/calico.yaml`

Manifests used by airshipctl for creating the target workload cluster can be found  in the section [target workload cluster](#target-workload-cluster)

$ airshipctl phase apply docker

```
kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/dtc-md-0 created
cluster.cluster.x-k8s.io/dtc created
machinedeployment.cluster.x-k8s.io/dtc-md-0 created
machinehealthcheck.cluster.x-k8s.io/dtc-mhc-0 created
kubeadmcontrolplane.controlplane.cluster.x-k8s.io/dtc-control-plane created
dockercluster.infrastructure.cluster.x-k8s.io/dtc created
dockermachinetemplate.infrastructure.cluster.x-k8s.io/dtc-control-plane created
dockermachinetemplate.infrastructure.cluster.x-k8s.io/dtc-md-0 created
```

$ docker ps

```
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                                  NAMES
f8f4a6bf14f6        kindest/node:v1.17.0           "/usr/local/bin/entr…"   2 minutes ago       Up 2 minutes                                               dtc-dtc-md-0-94c79cf9c-fvk2s
73d711354f6a        kindest/node:v1.17.0           "/usr/local/bin/entr…"   3 minutes ago       Up 2 minutes        45915/tcp, 127.0.0.1:45915->6443/tcp   dtc-dtc-control-plane-4dmv9
c8897b37a3c9        kindest/haproxy:2.1.1-alpine   "/docker-entrypoint.…"   3 minutes ago       Up 3 minutes        38901/tcp, 0.0.0.0:38901->6443/tcp     dtc-lb
b9690cecdcf2        kindest/node:v1.17.0           "/usr/local/bin/entr…"   17 minutes ago      Up 17 minutes       127.0.0.1:32773->6443/tcp              capi-docker-control-plane
```

$ kubectl get pods -A
```
NAMESPACE                           NAME                                                             READY   STATUS    RESTARTS   AGE
capd-system                         capd-controller-manager-75f5d546d7-xz4vm                         2/2     Running   0          7m8s
capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-5bb9bfdc46-n7dbk       2/2     Running   0          7m14s
capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-77466c7666-8fbw6   2/2     Running   0          7m11s
capi-system                         capi-controller-manager-5798474d9f-jzkrk                         2/2     Running   0          7m16s
capi-webhook-system                 capi-controller-manager-5d64dd9dfb-cqndz                         2/2     Running   0          7m17s
capi-webhook-system                 capi-kubeadm-bootstrap-controller-manager-7c78fff45-h9rkl        2/2     Running   0          7m15s
capi-webhook-system                 capi-kubeadm-control-plane-controller-manager-58465bb88f-7w22w   2/2     Running   0          7m13s
cert-manager                        cert-manager-69b4f77ffc-wtxzz                                    1/1     Running   0          7m47s
cert-manager                        cert-manager-cainjector-576978ffc8-5lchc                         1/1     Running   0          7m47s
cert-manager                        cert-manager-webhook-c67fbc858-tdzgt                             1/1     Running   2          7m47s
kube-system                         coredns-6955765f44-76mqd                                         1/1     Running   0          18m
kube-system                         coredns-6955765f44-jd62f                                         1/1     Running   0          18m
kube-system                         etcd-capi-docker-control-plane                                   1/1     Running   0          18m
kube-system                         kindnet-8q2jz                                                    1/1     Running   0          18m
kube-system                         kube-apiserver-capi-docker-control-plane                         1/1     Running   0          18m
kube-system                         kube-controller-manager-capi-docker-control-plane                1/1     Running   0          18m
kube-system                         kube-proxy-wp4lz                                                 1/1     Running   0          18m
kube-system                         kube-scheduler-capi-docker-control-plane                         1/1     Running   0          18m
local-path-storage                  local-path-provisioner-7745554f7f-wpfrv                          1/1     Running   0          18m
```

Controller logs can be checked using `kubectl logs capd-controller-manager-75f5d546d7-xz4vm  -n capd-system --all-containers=true -f  `

$ kubectl logs capd-controller-manager-75f5d546d7-xz4vm  -n capd-system --all-containers=true -f

```
I0710 08:53:15.083277       1 machine.go:236] controllers/DockerMachine/DockerMachine-controller "msg"="Running machine bootstrap scripts" "cluster"="dtc" "docker-cluster"="dtc" "docker-machine"={"Namespace":"default","Name":"dtc-md-0-54dgs"} "machine"="dtc-md-0-94c79cf9c-fvk2s"
I0710 08:53:22.100151       1 machine.go:264] controllers/DockerMachine/DockerMachine-controller "msg"="Setting Kubernetes node providerID" "cluster"="dtc" "docker-cluster"="dtc" "docker-machine"={"Namespace":"default","Name":"dtc-md-0-54dgs"} "machine"="dtc-md-0-94c79cf9c-fvk2s"
I0710 08:53:22.431332       1 generic_predicates.go:162] controllers/DockerMachine "msg"="Resource is not paused, will attempt to map resource" ""="dtc-md-0-54dgs" "namespace"="default" "predicate"="updateEvent"
I0710 08:53:22.444744       1 generic_predicates.go:162] controllers/DockerMachine "msg"="Resource is not paused, will attempt to map resource" ""="dtc-md-0-54dgs" "namespace"="default" "predicate"="updateEvent"
I0710 08:53:22.501492       1 generic_predicates.go:162] controllers/DockerMachine "msg"="Resource is not paused, will attempt to map resource" ""="dtc-md-0-54dgs" "namespace"="default" "predicate"="updateEvent"
I0710 08:53:22.504315       1 controller.go:272] controller-runtime/controller "msg"="Successfully Reconciled" "controller"="dockermachine" "name"="dtc-md-0-54dgs" "namespace"="default"
I0710 08:53:22.746239       1 generic_predicates.go:162] controllers/DockerMachine "msg"="Resource is not paused, will attempt to map resource" ""="dtc-md-0-94c79cf9c-fvk2s" "namespace"="default" "predicate"="updateEvent"
I0710 08:53:22.839181       1 generic_predicates.go:162] controllers/DockerMachine "msg"="Resource is not paused, will attempt to map resource" ""="dtc-md-0-94c79cf9c-fvk2s" "namespace"="default" "predicate"="updateEvent"
I0710 08:53:22.995287       1 controller.go:272] controller-runtime/controller "msg"="Successfully Reconciled" "controller"="dockermachine" "name"="dtc-md-0-54dgs" "namespace"="default"
I0710 08:53:23.125303       1 controller.go:272] controller-runtime/controller "msg"="Successfully Reconciled" "controller"="dockermachine" "name"="dtc-md-0-54dgs" "namespace"="default"
I0710 08:55:11.020648       1 reflector.go:419] pkg/mod/k8s.io/client-go@v0.17.7/tools/cache/reflector.go:105: Watch close - *v1alpha3.DockerCluster total 7 items received
I0710 08:55:43.123211       1 reflector.go:419] pkg/mod/k8s.io/client-go@v0.17.7/tools/cache/reflector.go:105: Watch close - *v1alpha3.Machine total 15 items received
I0710 08:56:09.014590       1 reflector.go:419] pkg/mod/k8s.io/client-go@v0.17.7/tools/cache/reflector.go:105: Watch close - *v1alpha3.DockerMachine total 19 items received
```

$ kubectl get machines

```
NAME                       PROVIDERID                                PHASE
dtc-control-plane-4dmv9    docker:////dtc-dtc-control-plane-4dmv9    Running
dtc-md-0-94c79cf9c-fvk2s   docker:////dtc-dtc-md-0-94c79cf9c-fvk2s   Running
```

$ kubectl --namespace=default get secret/dtc-kubeconfig -o jsonpath={.data.value} | base64 --decode > ./dtc.kubeconfig

$ kubectl get nodes --kubeconfig dtc.kubeconfig

```
NAME                           STATUS   ROLES    AGE     VERSION
dtc-dtc-control-plane-4dmv9    Ready    master   8m      v1.17.0
dtc-dtc-md-0-94c79cf9c-fvk2s   Ready    <none>   7m31s   v1.17.0
```

$ kubectl get pods -A  --kubeconfig dtc.kubeconfig

```
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-65c8dd596b-sdwf9              1/1     Running   0          11m
kube-system   calico-node-v86l5                                     1/1     Running   0          11m
kube-system   calico-node-ztm5l                                     1/1     Running   0          11m
kube-system   coredns-6955765f44-b7hwk                              1/1     Running   0          11m
kube-system   coredns-6955765f44-bbhzp                              1/1     Running   0          11m
kube-system   etcd-dtc-dtc-control-plane-4dmv9                      1/1     Running   0          11m
kube-system   kube-apiserver-dtc-dtc-control-plane-4dmv9            1/1     Running   0          11m
kube-system   kube-controller-manager-dtc-dtc-control-plane-4dmv9   1/1     Running   0          11m
kube-system   kube-proxy-7vvn5                                      1/1     Running   0          11m
kube-system   kube-proxy-jb8kk                                      1/1     Running   0          11m
kube-system   kube-scheduler-dtc-dtc-control-plane-4dmv9            1/1     Running   0          11m
```

## Reference

### Cluster Api Docker Provider Manifests

Manifests for cluster api docker provider - capd, are available under `airshipctl/manifests/function/capd`

`$ tree airshipctl/manifests/function/capd`

```
manifests/function/capd
├── clusterctl-settings.json
├── docker-overrides.py
└── v0.3.0
    ├── certmanager
    │   ├── certificate.yaml
    │   ├── kustomization.yaml
    │   └── kustomizeconfig.yaml
    ├── crd
    │   ├── bases
    │   │   ├── infrastructure.cluster.x-k8s.io_dockerclusters.yaml
    │   │   ├── infrastructure.cluster.x-k8s.io_dockermachines.yaml
    │   │   └── infrastructure.cluster.x-k8s.io_dockermachinetemplates.yaml
    │   ├── kustomization.yaml
    │   ├── kustomizeconfig.yaml
    │   └── patches
    │       ├── cainjection_in_dockerclusters.yaml
    │       ├── cainjection_in_dockermachines.yaml
    │       ├── webhook_in_dockerclusters.yaml
    │       └── webhook_in_dockermachines.yaml
    ├── default
    │   ├── kustomization.yaml
    │   └── namespace.yaml
    ├── kustomization.yaml
    ├── manager
    │   ├── kustomization.yaml
    │   ├── manager_auth_proxy_patch.yaml
    │   ├── manager_image_patch.yaml
    │   ├── manager_prometheus_metrics_patch.yaml
    │   ├── manager_pull_policy.yaml
    │   └── manager.yaml
    ├── rbac
    │   ├── auth_proxy_role_binding.yaml
    │   ├── auth_proxy_role.yaml
    │   ├── auth_proxy_service.yaml
    │   ├── kustomization.yaml
    │   ├── leader_election_role_binding.yaml
    │   ├── leader_election_role.yaml
    │   ├── role_binding.yaml
    │   └── role.yaml
    └── webhook
        ├── kustomization.yaml
        ├── kustomizeconfig.yaml
        ├── manager_webhook_patch.yaml
        ├── manifests.yaml
        ├── service.yaml
        └── webhookcainjection_patch.yaml

9 directories, 37 files
```

The root directory for cluster api docker provider is airshipctl/manifests/function/capd.

`v0.3.0` contains the content of the config directory referenced from  https://github.com/kubernetes-sigs/cluster-api/tree/master/test/infrastructure/docker/config

### Local Overrides For Docker

Generally,  all cluster api provider repositories  provide metadata.yaml, and infrastrucuture-components.yaml. The metadata.yaml and components.yaml is used at the time of initializing the management cluster with provider components. The metadata is not part of local manifests, and is fetched from the provider repository at runtime, when `airshipctl cluster init` is executed.
Here is an example of  provider `cluster api` fetching `components.yaml` and `metadata.yaml`

$ airship cluster init --debug

```
[airshipctl] 2020/07/01 10:48:41 Starting cluster-api initiation
Installing the clusterctl inventory CRD
Creating CustomResourceDefinition="providers.clusterctl.cluster.x-k8s.io"
Fetching providers
Provider type: CoreProvider, name: cluster-api
[airshipctl] 2020/07/01 10:48:41 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: CoreProvider, name: cluster-api
Fetching File="components.yaml" Provider="cluster-api" Version="v0.3.3"
Fetching File="metadata.yaml" Provider="cluster-api" Version="v0.3.3"
```

To get a list of cluster api providers and their repository configurations, run the below command

$ clusterctl config repositories

```
NAME          TYPE                     URL
cluster-api   CoreProvider             https://github.com/kubernetes-sigs/cluster-api/releases/latest/core-components.yaml
kubeadm       BootstrapProvider        https://github.com/kubernetes-sigs/cluster-api/releases/latest/bootstrap-components.yaml
kubeadm       ControlPlaneProvider     https://github.com/kubernetes-sigs/cluster-api/releases/latest/control-plane-components.yaml
aws           InfrastructureProvider   https://github.com/kubernetes-sigs/cluster-api-provider-aws/releases/latest/infrastructure-components.yaml
azure         InfrastructureProvider   https://github.com/kubernetes-sigs/cluster-api-provider-azure/releases/latest/infrastructure-components.yaml
metal3        InfrastructureProvider   https://github.com/metal3-io/cluster-api-provider-metal3/releases/latest/infrastructure-components.yaml
openstack     InfrastructureProvider   https://github.com/kubernetes-sigs/cluster-api-provider-openstack/releases/latest/infrastructure-components.yaml
vsphere       InfrastructureProvider   https://github.com/kubernetes-sigs/cluster-api-provider-vsphere/releases/latest/infrastructure-components.yaml
```

Unlike other infrastructure providers, docker does not have its own publicly available config repository offering the metadata.yaml and infrastrucutre-components.yaml files.
Therefore, `airshipctl cluster init` fails when  metadata  can't be fetched at runtime.

$ airshipctl cluster init --debug

```
[airshipctl] 2020/06/29 06:23:35 Starting cluster-api initiation
[airshipctl] 2020/06/29 06:23:35 Creating arishipctl repository implementation interface for provider cluster-api of type CoreProvider
[airshipctl] 2020/06/29 06:23:35 Creating arishipctl repository implementation interface for provider kubeadm of type BootstrapProvider
[airshipctl] 2020/06/29 06:23:35 Creating arishipctl repository implementation interface for provider kubeadm of type ControlPlaneProvider
[airshipctl] 2020/06/29 06:23:35 Creating arishipctl repository implementation interface for provider docker of type InfrastructureProvider
[airshipctl] 2020/06/29 06:23:35 Creating arishipctl repository implementation interface for provider cluster-api of type CoreProvider
[airshipctl] 2020/06/29 06:23:35 Creating arishipctl repository implementation interface for provider kubeadm of type BootstrapProvider
[airshipctl] 2020/06/29 06:23:36 Creating arishipctl repository implementation interface for provider kubeadm of type ControlPlaneProvider
[airshipctl] 2020/06/29 06:23:36 Creating arishipctl repository implementation interface for provider docker of type InfrastructureProvider
failed to read "metadata.yaml" from the repository for provider "infrastructure-docker": document filtered by selector [Group="clusterctl.cluster.x-k8s.io", Version="v1alpha3", Kind="Metadata"] found no documents
```

The reference implementation for cluster api using docker as infrastructure provider is available as a part of the cluster api code base `https://github.com/kubernetes-sigs/cluster-api/tree/master/test/infrastructure/docker`. It provides a `hack` https://github.com/kubernetes-sigs/cluster-api/blob/master/cmd/clusterctl/hack/local-overrides.py to generate this metadata from cluster api repository.

Similary for `airshipctl`, this metadata can be generated using the `docker-overrides.py` which is similar to `https://github.com/kubernetes-sigs/cluster-api/blob/master/cmd/clusterctl/hack/local-overrides.py`. However, it generates the metadata only for infrastrucure provider component `docker`

`docker-overrides.py` uses `clusterctl-settings.json`  to  read from the local repository `airshipctl/manifests/function/capd/v0.3.0` and generate metatdata for infrastructure provider type `docker`. This metadata is used at the time of initializing the management cluster with docker provider component.

`docker-overrides.py` builds the providers’ assets, and places them in a local override folder located under `$HOME/.cluster-api/overrides/`

`$ cat clusterctl-settings.json`

```
{
  "providers": ["infrastructure-docker"],
  "provider_repos": []
}
```

`$ ./docker-overrides.py`

```
airshipctl local overrides generated from the local repository for docker provider airshipctl/manifests/function/capd/v0.3.0
in order to use them, please run:

airshipctl cluster init --debug
```

`$ tree  ~/.cluster-api`

```
~/.cluster-api
└── overrides
    └── infrastructure-docker
        └── v0.3.0
            ├── infrastructure-components.yaml
            └── metadata.yaml

3 directories, 2 files
```

As a result, when `airshipctl cluster init` initializes the management cluster with infrastructure-provider `docker` component, it uses the metadata available at `$HOME/.cluster-api/overrides/`

$ airshipctl cluster init --debug

```
Provider type: InfrastructureProvider, name: docker
Fetching File="components.yaml" Provider="infrastructure-docker" Version="v0.3.0"
[airshipctl] 2020/07/01 10:48:42 Building cluster-api provider component documents from kustomize path at /tmp/airship/airshipctl/manifests/function/capd/v0.3.0
[airshipctl] 2020/07/01 10:48:42 Creating arishipctl repository implementation interface for provider cluster-api of type CoreProvider
[airshipctl] 2020/07/01 10:48:43 Creating arishipctl repository implementation interface for provider docker of type InfrastructureProvider
Using Override="metadata.yaml" Provider="infrastructure-docker" Version="v0.3.0"
```

### CAPD Manager Image Version

`airshipctl/manifests/function/capd/v0.3.0/manager/manager_image_patch.yaml`

The capd-manager version to be used is configured in `manager_image_patch.yaml`

`$ cat manager_image_patch.yaml`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: controller-manager
  namespace: system
spec:
  template:
    spec:
      containers:
      # Change the value of image field below to your controller image URL
      - image: gcr.io/k8s-staging-cluster-api/capd-manager:master
        name: manager

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

#### Management cluster

`airshipctl cluster init` uses to information in `manifests/site/docker-test-site/shared/clusterctl/clusterctl.yaml` to initialize the management cluster with cluster api and cluster api docker provider components.

`$cat clusterctl.yaml`

```
apiVersion: airshipit.org/v1alpha1
kind: Clusterctl
metadata:
  labels:
    airshipit.org/deploy-k8s: "false"
  name: clusterctl-v1
init-options:
  core-provider: "cluster-api:v0.3.3"
  bootstrap-providers:
    - "kubeadm:v0.3.3"
  infrastructure-providers:
    - "docker:v0.3.0"
  control-plane-providers:
    - "kubeadm:v0.3.3"
providers:
  - name: "docker"
    type: "InfrastructureProvider"
    versions:
      v0.3.0: airshipctl/manifests/function/capd/v0.3.0
  - name: "kubeadm"
    type: "BootstrapProvider"
    versions:
      v0.3.3: airshipctl/manifests/function/cabpk/v0.3.3
  - name: "cluster-api"
    type: "CoreProvider"
    versions:
      v0.3.3: airshipctl/manifests/function/capi/v0.3.3
  - name: "kubeadm"
    type: "ControlPlaneProvider"
    versions:
      v0.3.3: airshipctl/manifests/function/cacpk/v0.3.3

```

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
      joinConfiguration:
        nodeRegistration:
          criSocket: /var/run/containerd/containerd.sock
          kubeletExtraArgs:
            eviction-hard: nodefs.available<0%,nodefs.inodesFree<0%,imagefs.available<0%
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

### Airshipctl Configuration File

The below configuration shows the final state of `~/.airship/config` post deployment of a management cluster and a workload cluster.

There are two clusters kind-capi-docker - the management cluster, and dtc - target workload cluster.

`airshipctl config get-context` can be used to get information on the contexts, and the manifests used by each context.

`$ cat ~/.airship/config`

```

apiVersion: airshipit.org/v1alpha1
bootstrapInfo:
  default:
    builder:
      networkConfigFileName: network-config
      outputMetadataFileName: output-metadata.yaml
      userDataFileName: user-data
    container:
      containerRuntime: docker
      image: quay.io/airshipit/isogen:latest-debian_stable
      volume: /srv/iso:/config
    remoteDirect:
      isoUrl: http://localhost:8099/debian-custom.iso
clusters:
  dtc:
    clusterType:
      target:
        bootstrapInfo: default
        clusterKubeconf: dtc_target
        managementConfiguration: default
  kind-capi-docker:
    clusterType:
      target:
        bootstrapInfo: default
        clusterKubeconf: kind-capi-docker_target
        managementConfiguration: default
contexts:
  dtc-admin@dtc:
    contextKubeconf: dtc_target
    manifest: docker_manifest
  kind-capi-docker:
    contextKubeconf: kind-capi-docker_target
    manifest: docker_manifest
currentContext: kind-capi-docker
kind: Config
managementConfiguration:
  default:
    systemActionRetries: 30
    systemRebootDelay: 30
    type: redfish
manifests:
  default:
    primaryRepositoryName: primary
    repositories:
      primary:
        checkout:
          branch: master
          commitHash: ""
          force: false
          tag: ""
        url: https://opendev.org/airship/treasuremap
    subPath: treasuremap/manifests/site
    targetPath: /tmp/default
  docker_manifest:
    primaryRepositoryName: primary
    repositories:
      primary:
        checkout:
          branch: master
          commitHash: ""
          force: false
          tag: ""
        url: https://review.opendev.org/airship/airshipctl
    subPath: airshipctl/manifests/site/docker-test-site
    targetPath: /tmp/airship
users:
  dtc-admin: {}
  kind-capi-docker: {}

```

$ airshipctl config get-context

```
Context: dtc
contextKubeconf: dtc_target
manifest: docker_manifest

LocationOfOrigin: /home/rishabh/.airship/kubeconfig
cluster: dtc_target
user: dtc-admin


Context: kind-capi-docker
contextKubeconf: kind-capi-docker_target
manifest: docker_manifest

LocationOfOrigin: /home/rishabh/.airship/kubeconfig
cluster: kind-capi-docker_target
user: kind-capi-docker
```

### Software Version Information

All the instructions provided in the document have been tested using the software and version, provided in this section.

#### Docker

$ docker version

```
Client: Docker Engine - Community
 Version:           19.03.9
 API version:       1.40
 Go version:        go1.13.10
 Git commit:        9d988398e7
 Built:             Fri May 15 00:25:18 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.9
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.10
  Git commit:       9d988398e7
  Built:            Fri May 15 00:23:50 2020
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

All the instructions in the document were perfomed on a Oracle Virtual Box VM running Ubuntu 18.04.4 LTS (Bionic Beaver) with 16G of memory and 4 VCPUs

## Future Improvements

This section includes the some of the potential improvements that can be made with airshipctl and cluster api  docker integration.

### Remove usage of docker overrides

`infrastructure-components.yaml` and `metadata.yaml` can be included as a part of the the cluster api docker manifests in the following manner:

```
manifests/function/capd
└── v0.3.0
    ├── infrastructure-docker
    │   └── v0.3.0
    │       ├── infrastructure-components.yaml
    │       └── metadata.yaml
```

And, docker provider configuration in `clusterctl.yaml` can use a local url to reference the `infrastructure-components.yaml`.

$ cat  manifests/site/docker-test-site/shared/clusterctl/clusterctl.yaml

```
apiVersion: airshipit.org/v1alpha1
kind: Clusterctl
metadata:
  labels:
    airshipit.org/deploy-k8s: "false"
  name: clusterctl-v1
init-options:
  infrastructure-providers:
    - "docker:v0.3.0"
providers:
  - name: "docker"
    type: "InfrastructureProvider"
    url: "/tmp/airship/airshipctl/manifests/function/capd/v0.3.0/infrastructure-docker/v0.3.0/infrastructure-components.yaml"
    clusterctl-repository: true

```
However, this approach requires airshipctl configuration to include manifests in the following manner:

```
  docker_manifest:
    primaryRepositoryName: primary
    repositories:
      primary:
        checkout:
          branch: master
          commitHash: ""
          force: false
          tag: ""
        url: https://review.opendev.org/airship/airshipctl
    subPath: airshipctl/manifests/site/docker-test-site
    targetPath: /tmp/airship
```

This would make sure that when `airshipctl document pull` is executed, the `url` field in `clusterctl.yaml` configuration file,  would refer to a valid path - `/tmp/airship/airshipctl/manifests/function/capd/v0.3.0/infrastructure-docker/v0.3.0/infrastructure-components.yaml` on the local file system.
If this approach is used in future, one would not have to run the local overrides hack for docker before executing `airshipctl cluster init`.

## See Also

### Zuul Check And Testing Scripts Locally

* [Zuul Check And Testing Scripts Locally](tests/README.md)