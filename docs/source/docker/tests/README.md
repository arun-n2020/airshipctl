# Zuul Check And Testing Scripts Locally

## Table of Contents
- [Zuul Check And Testing Scripts Locally](#zuul-check-and-testing-scripts-locally)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Scripts And Usage](#scripts-and-usage)
  - [Video Demonstration](#video-demonstration)
  - [Testing Zuul Scripts Locally](#testing-zuul-scripts-locally)
  - [See Also](#see-also)
    - [Airshipctl And Cluster API Docker Integration](#airshipctl-and-cluster-api-docker-integration)

## Overview

Zuul Check for testing `airshipctl and cluster api docker integration` is being handled by the job -  `airship-airshipctl-gate-script-runner-dockertest`, included in the patchset `https://review.opendev.org/#/c/738682/`

This document contains information on usage of the scripts in patchset `https://review.opendev.org/#/c/738682/` to test
`airshipctl and cluster api docker integration` locally.

Airshipctl and cluster api docker integration is available as a part of patchset - `https://review.opendev.org/#/c/737871/`

For more information on airshipctl and cluster api docker integration visit [Airshipctl And Cluster API Docker Integration](../README.md)

## Scripts And Usage

| script name                                                 | purpose                                                                                                                                                                                                            |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| tools/deployment/docker/00_install_kind.sh                  | - install kind and display kind version                                                                                                                                                                            |
| tools/deployment/docker/02_install_go.sh                    | - install go and add go to systems's PATH variable                                                                                                                                                                 |
| tools/deployment/docker/03_install_kustomize_docker.sh      | - install kustomize and apache2 service <br> - start apache2 service                                                                                                                                               |
| tools/deployment/docker/11_build_kind_cluster.sh            | - create kind cluster with one control plane <br> - test if all pods are up                                                                                                                                        |
| tools/deployment/docker/21_systemwide_executable.sh         | - install airshipctl                                                                                                                                                                                               |
| tools/deployment/docker/31_create_configs.sh                | - generate airship kubeconfig <br> - generate airship config file from template                                                                                                                                    |
| tools/deployment/docker/41_initialize_management_cluster.sh | - execute local overrides to generate docker provider metadata <br> - initialize kind cluster with cluster api and cluster api docker provider components <br> - test if control plane is up                                                                                            |
| tools/deployment/docker/51_deploy_workload_cluster.sh       | - create workload cluster and deploy calico as cni solution to the workload cluster <br> - check if all nodes are ready on workload cluster <br> - check if all pods are running on workload cluster |

## Video Demonstration

A video demonstrating  local execution of the scripts included in patchset `https://review.opendev.org/#/c/738682/` to test `airshipctl and cluster api docker integration`

[![asciicast](https://asciinema.org/a/DSW3FebvE7Gl5a6upMA5PWBHL.svg)](https://asciinema.org/a/DSW3FebvE7Gl5a6upMA5PWBHL)

## Testing Zuul Scripts Locally

`$ ./tools/deployment/docker/00_install_kind.sh`

```
Installing Kind
Kind Installed
kind v0.7.0 go1.13.6 linux/amd64
❯ ./tools/deployment/docker/01_install_kubectl.sh
+ : v1.17.4
+ URL=https://storage.googleapis.com
+ sudo -E curl -sSLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.4/bin/linux/amd64/kubectl
+ sudo -E chmod +x /usr/local/bin/kubectl
```

`$ ./tools/deployment/docker/02_install_go.sh`
```
Installing GO
--2020-07-13 12:48:59--  https://dl.google.com/go/go1.14.1.linux-amd64.tar.gz
Resolving dl.google.com (dl.google.com)... 172.217.14.238, 2607:f8b0:400a:803::200e
Connecting to dl.google.com (dl.google.com)|172.217.14.238|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 123631885 (118M) [application/octet-stream]
Saving to: ‘go1.14.1.linux-amd64.tar.gz’

go1.14.1.linux-amd64.tar.gz                    100%[====================================================================================================>] 117.90M  23.5MB/s    in 5.2s

2020-07-13 12:49:04 (22.8 MB/s) - ‘go1.14.1.linux-amd64.tar.gz’ saved [123631885/123631885]

/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/rishabh/projects/airshipctl:/home/rishabh/go/bin:/usr/local/go/bin:/home/rishabh/projects/airshipctl:/home/rishabh/go/bin:/usr/local/go/bin
```

`$ ./tools/deployment/docker/03_install_kustomize_docker.sh`

```
{Version:kustomize/v3.8.0 GitCommit:6a50372dd5686df22750b0c729adaf369fbf193c BuildDate:2020-07-05T14:08:42Z GoOs:linux GoArch:amd64}
kustomize installed to current directory.
Hit:1 https://download.docker.com/linux/ubuntu bionic InRelease
Hit:3 http://us.archive.ubuntu.com/ubuntu bionic InRelease
Hit:4 http://packages.microsoft.com/repos/vscode stable InRelease
Get:5 http://us.archive.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]
Hit:2 https://packages.cloud.google.com/apt kubernetes-xenial InRelease
Hit:6 https://packages.microsoft.com/repos/azure-cli bionic InRelease
Hit:7 http://ppa.launchpad.net/dawidd0811/neofetch/ubuntu bionic InRelease
Get:8 http://us.archive.ubuntu.com/ubuntu bionic-backports InRelease [74.6 kB]
Get:9 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]
Hit:10 http://ppa.launchpad.net/zanchey/asciinema/ubuntu bionic InRelease
Get:11 http://us.archive.ubuntu.com/ubuntu bionic-updates/main amd64 DEP-11 Metadata [295 kB]
Get:12 http://us.archive.ubuntu.com/ubuntu bionic-updates/universe amd64 DEP-11 Metadata [279 kB]
Get:13 http://us.archive.ubuntu.com/ubuntu bionic-updates/universe DEP-11 48x48 Icons [213 kB]
Get:14 http://us.archive.ubuntu.com/ubuntu bionic-updates/multiverse amd64 DEP-11 Metadata [2,468 B]
Get:15 http://us.archive.ubuntu.com/ubuntu bionic-backports/universe amd64 DEP-11 Metadata [9,288 B]
Get:16 http://security.ubuntu.com/ubuntu bionic-security/main amd64 DEP-11 Metadata [46.0 kB]
Get:17 http://security.ubuntu.com/ubuntu bionic-security/universe amd64 DEP-11 Metadata [49.2 kB]
Get:18 http://security.ubuntu.com/ubuntu bionic-security/multiverse amd64 DEP-11 Metadata [2,464 B]
Fetched 1,148 kB in 3s (354 kB/s)
Reading package lists... Done
Building dependency tree
Reading state information... Done
80 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree
Reading state information... Done
apache2 is already the newest version (2.4.29-1ubuntu4.13).
The following packages were automatically installed and are no longer required:
  efibootmgr gir1.2-geocodeglib-1.0 libfwup1 libllvm8 ubuntu-web-launchers
Use 'sudo apt autoremove' to remove them.
0 upgraded, 0 newly installed, 0 to remove and 80 not upgraded.
● apache2.service - The Apache HTTP Server
   Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
  Drop-In: /lib/systemd/system/apache2.service.d
           └─apache2-systemd.conf
   Active: active (running) since Mon 2020-07-13 11:14:40 PDT; 1h 35min ago
  Process: 1255 ExecStart=/usr/sbin/apachectl start (code=exited, status=0/SUCCESS)
 Main PID: 1302 (apache2)
    Tasks: 55 (limit: 4915)
   CGroup: /system.slice/apache2.service
           ├─1302 /usr/sbin/apache2 -k start
           ├─1303 /usr/sbin/apache2 -k start
           └─1304 /usr/sbin/apache2 -k start

Jul 13 11:14:39 ws-01-dev systemd[1]: Starting The Apache HTTP Server...
Jul 13 11:14:40 ws-01-dev apachectl[1255]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globallyJul 13 11:14:40 ws-01-dev systemd[1]: Started The Apache HTTP Server.
```

`$ ./tools/deployment/docker/11_build_kind_cluster.sh`

```
+ export TIMEOUT=3600
+ TIMEOUT=3600
+ export KUBECONFIG=/home/rishabh/.kube/config
+ KUBECONFIG=/home/rishabh/.kube/config
+ REMOTE_WORK_DIR=/tmp
+ echo 'Create Kind Cluster'
Create Kind Cluster
+ cat
+ kind delete cluster --name capi-docker
Deleting cluster "capi-docker" ...
+ kind delete cluster --name dtc
Deleting cluster "dtc" ...
+ kind create cluster --config /tmp/kind-cluster-with-extramounts.yaml --name capi-docker
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

Have a nice day! 👋
++ date +%s
+ end=1594673464
+ echo 'Waiting 3600 seconds for Capi Docker Control Plane node to be ready.'
Waiting 3600 seconds for Capi Docker Control Plane node to be ready.
+ true
+ kubectl --request-timeout 20s --kubeconfig /home/rishabh/.kube/config get nodes capi-docker-control-plane -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}'
+ grep -q True
++ date +%s
+ now=1594669864
+ '[' 1594669864 -gt 1594673464 ']'
+ echo -n .
.+ sleep 15
+ true
+ grep -q True
+ kubectl --request-timeout 20s --kubeconfig /home/rishabh/.kube/config get nodes capi-docker-control-plane -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}'
++ date +%s
+ now=1594669879
+ '[' 1594669879 -gt 1594673464 ']'
+ echo -n .
.+ sleep 15
+ true
+ kubectl --request-timeout 20s --kubeconfig /home/rishabh/.kube/config get nodes capi-docker-control-plane -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}'
+ grep -q True
++ date +%s
+ now=1594669894
+ '[' 1594669894 -gt 1594673464 ']'
+ echo -n .
.+ sleep 15
+ true
+ grep -q True
+ kubectl --request-timeout 20s --kubeconfig /home/rishabh/.kube/config get nodes capi-docker-control-plane -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}'
++ date +%s
+ now=1594669909
+ '[' 1594669909 -gt 1594673464 ']'
+ echo -n .
.+ sleep 15
+ true
+ kubectl --request-timeout 20s --kubeconfig /home/rishabh/.kube/config get nodes capi-docker-control-plane -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}'
+ grep -q True
+ echo -e '\nCapi Docker Control Plane Node is ready.'

Capi Docker Control Plane Node is ready.
+ kubectl --request-timeout 20s --kubeconfig /home/rishabh/.kube/config get nodes
NAME                        STATUS   ROLES    AGE   VERSION
capi-docker-control-plane   Ready    master   70s   v1.17.0
+ break
```

`$ ./tools/deployment/docker/21_systemwide_executable.sh`

```
+ export USE_PROXY=false
+ USE_PROXY=false
+ export HTTPS_PROXY=
+ HTTPS_PROXY=
+ export HTTPS_PROXY=
+ HTTPS_PROXY=
+ export NO_PROXY=
+ NO_PROXY=
+ echo 'Build airshipctl in docker image'
Build airshipctl in docker image
+ make docker-image
Sending build context to Docker daemon  13.87MB
Step 1/16 : ARG GO_IMAGE=docker.io/golang:1.13.1-stretch
Step 2/16 : ARG RELEASE_IMAGE=scratch
Step 3/16 : FROM ${GO_IMAGE} as builder
 ---> f8c4e1a86e6d
Step 4/16 : COPY ./certs/* /usr/local/share/ca-certificates/
 ---> Using cache
 ---> bd8bea3d952b
Step 5/16 : RUN update-ca-certificates
 ---> Using cache
 ---> 777f06a1cfb1
Step 6/16 : SHELL [ "/bin/bash", "-cex" ]
 ---> Using cache
 ---> b26acfdbb328
Step 7/16 : WORKDIR /usr/src/airshipctl
 ---> Using cache
 ---> 83861d8facc8
Step 8/16 : COPY go.mod go.sum /usr/src/airshipctl/
 ---> Using cache
 ---> 6eed7eba155e
Step 9/16 : RUN go mod download
 ---> Using cache
 ---> c022a5e53b90
Step 10/16 : COPY . /usr/src/airshipctl/
 ---> 4578508fa224
Step 11/16 : ARG MAKE_TARGET=build
 ---> Running in af4df6672ceb
Removing intermediate container af4df6672ceb
 ---> 08cde0959f17
Step 12/16 : RUN for target in $MAKE_TARGET; do make $target; done
 ---> Running in 7cdf86489545
+ for target in $MAKE_TARGET
+ make build
Removing intermediate container 7cdf86489545
 ---> b290d5250fd9
Step 13/16 : FROM ${RELEASE_IMAGE} as release
 --->
Step 14/16 : COPY --from=builder /usr/src/airshipctl/bin/airshipctl /usr/local/bin/airshipctl
 ---> Using cache
 ---> 755d2ac362ee
Step 15/16 : USER 65534
 ---> Using cache
 ---> fe9fa695a587
Step 16/16 : ENTRYPOINT [ "/usr/local/bin/airshipctl" ]
 ---> Using cache
 ---> 80fefa895e2d
Successfully built 80fefa895e2d
Successfully tagged quay.io/airshipit/airshipctl:dev
+ echo 'Copy airshipctl from docker image'
Copy airshipctl from docker image
++ make print-docker-image-tag
+ DOCKER_IMAGE_TAG=quay.io/airshipit/airshipctl:dev
++ docker create quay.io/airshipit/airshipctl:dev
+ CONTAINER=d2a20705cccc16155ca3bafadf8741dab087bfcb0566c4d34e481650f3bc21c2
+ sudo docker cp d2a20705cccc16155ca3bafadf8741dab087bfcb0566c4d34e481650f3bc21c2:/usr/local/bin/airshipctl /usr/local/bin/airshipctl
+ sudo docker rm d2a20705cccc16155ca3bafadf8741dab087bfcb0566c4d34e481650f3bc21c2
d2a20705cccc16155ca3bafadf8741dab087bfcb0566c4d34e481650f3bc21c2
+ airshipctl version
+ grep -q airshipctl
+ echo 'Airshipctl version'
Airshipctl version
+ airshipctl version
airshipctl:   v0.1.0
```

`$ ./tools/deployment/docker/31_create_configs.sh`
```
+ export ISO_DIR=/srv/iso
+ ISO_DIR=/srv/iso
+ export SERVE_PORT=8099
+ SERVE_PORT=8099
+ export AIRSHIPCTL_WS=/home/rishabh/projects/airshipctl
+ AIRSHIPCTL_WS=/home/rishabh/projects/airshipctl
+ export USER_NAME=rishabh
+ USER_NAME=rishabh
+ export USE_PROXY=false
+ USE_PROXY=false
+ export HTTPS_PROXY=
+ HTTPS_PROXY=
+ export HTTPS_PROXY=
+ HTTPS_PROXY=
+ export NO_PROXY=
+ NO_PROXY=
+ export REMOTE_WORK_DIR=/tmp/airship
+ REMOTE_WORK_DIR=/tmp/airship
+ export AIRSHIP_CONFIG_ISO_GEN_TARGET_PATH=/srv/iso
+ AIRSHIP_CONFIG_ISO_GEN_TARGET_PATH=/srv/iso
+ export AIRSHIP_CONFIG_ISO_BUILDER_DOCKER_IMAGE=quay.io/airshipit/isogen:latest-debian_stable
+ AIRSHIP_CONFIG_ISO_BUILDER_DOCKER_IMAGE=quay.io/airshipit/isogen:latest-debian_stable
+ export REMOTE_TYPE=redfish
+ REMOTE_TYPE=redfish
+ export REMOTE_INSECURE=true
+ REMOTE_INSECURE=true
+ export REMOTE_PROXY=false
+ REMOTE_PROXY=false
+ export AIRSHIP_CONFIG_ISO_SERVE_HOST=localhost
+ AIRSHIP_CONFIG_ISO_SERVE_HOST=localhost
+ export AIRSHIP_CONFIG_ISO_PORT=8099
+ AIRSHIP_CONFIG_ISO_PORT=8099
+ export AIRSHIP_CONFIG_ISO_NAME=debian-custom.iso
+ AIRSHIP_CONFIG_ISO_NAME=debian-custom.iso
+ export SYSTEM_ACTION_RETRIES=30
+ SYSTEM_ACTION_RETRIES=30
+ export SYSTEM_REBOOT_DELAY=30
+ SYSTEM_REBOOT_DELAY=30
+ export AIRSHIP_CONFIG_PRIMARY_REPO_BRANCH=master
+ AIRSHIP_CONFIG_PRIMARY_REPO_BRANCH=master
+ export AIRSHIP_CONFIG_PRIMARY_REPO_URL=https://review.opendev.org/airship/airshipctl
+ AIRSHIP_CONFIG_PRIMARY_REPO_URL=https://review.opendev.org/airship/airshipctl
+ export AIRSHIP_SITE_NAME=manifests/site/docker-test-site
+ AIRSHIP_SITE_NAME=manifests/site/docker-test-site
+ export AIRSHIP_CONFIG_MANIFEST_DIRECTORY=
+ AIRSHIP_CONFIG_MANIFEST_DIRECTORY=
++ cat tools/deployment/certificates/airship_config_ca_data
++ base64 -w0
+ export AIRSHIP_CONFIG_CA_DATA=LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1USXlOakE0TWpneU5Gb1hEVEk1TVRJeU16QTRNamd5TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTTFSClM0d3lnajNpU0JBZjlCR0JUS1p5VTFwYmdDaGQ2WTdJektaZWRoakM2K3k1ZEJpWm81ZUx6Z2tEc2gzOC9YQ1MKenFPS2V5cE5RcDN5QVlLdmJKSHg3ODZxSFZZNjg1ZDVYVDNaOHNyVVRzVDR5WmNzZHAzV3lHdDM0eXYzNi9BSQoxK1NlUFErdU5JemN6bzNEdWhXR0ZoQjk3VjZwRitFUTBlVWN5bk05c2hkL3AwWVFzWDR1ZlhxaENENVpzZnZUCnBka3UvTWkyWnVGUldUUUtNeGpqczV3Z2RBWnBsNnN0L2ZkbmZwd1Q5cC9WTjRuaXJnMEsxOURTSFFJTHVrU2MKb013bXNBeDJrZmxITWhPazg5S3FpMEloL2cyczRFYTRvWURZemt0Y2JRZ24wd0lqZ2dmdnVzM3pRbEczN2lwYQo4cVRzS2VmVGdkUjhnZkJDNUZNQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFJek9BL00xWmRGUElzd2VoWjFuemJ0VFNURG4KRHMyVnhSV0VnclFFYzNSYmV3a1NkbTlBS3MwVGR0ZHdEbnBEL2tRYkNyS2xEeFF3RWg3NFZNSFZYYkFadDdsVwpCSm90T21xdXgxYThKYklDRTljR0FHRzFvS0g5R29jWERZY0JzOTA3ckxIdStpVzFnL0xVdG5hN1dSampqZnBLCnFGelFmOGdJUHZIM09BZ3B1RVVncUx5QU8ya0VnelZwTjZwQVJxSnZVRks2TUQ0YzFmMnlxWGxwNXhrN2dFSnIKUzQ4WmF6d0RmWUVmV3Jrdld1YWdvZ1M2SktvbjVEZ0Z1ZHhINXM2Snl6R3lPVnZ0eG1TY2FvOHNxaCs3UXkybgoyLzFVcU5ZK0hlN0x4d04rYkhwYkIxNUtIMTU5ZHNuS3BRbjRORG1jSTZrVnJ3MDVJMUg5ZGRBbGF0bz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
+ AIRSHIP_CONFIG_CA_DATA=LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRFNU1USXlOakE0TWpneU5Gb1hEVEk1TVRJeU16QTRNamd5TkZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTTFSClM0d3lnajNpU0JBZjlCR0JUS1p5VTFwYmdDaGQ2WTdJektaZWRoakM2K3k1ZEJpWm81ZUx6Z2tEc2gzOC9YQ1MKenFPS2V5cE5RcDN5QVlLdmJKSHg3ODZxSFZZNjg1ZDVYVDNaOHNyVVRzVDR5WmNzZHAzV3lHdDM0eXYzNi9BSQoxK1NlUFErdU5JemN6bzNEdWhXR0ZoQjk3VjZwRitFUTBlVWN5bk05c2hkL3AwWVFzWDR1ZlhxaENENVpzZnZUCnBka3UvTWkyWnVGUldUUUtNeGpqczV3Z2RBWnBsNnN0L2ZkbmZwd1Q5cC9WTjRuaXJnMEsxOURTSFFJTHVrU2MKb013bXNBeDJrZmxITWhPazg5S3FpMEloL2cyczRFYTRvWURZemt0Y2JRZ24wd0lqZ2dmdnVzM3pRbEczN2lwYQo4cVRzS2VmVGdkUjhnZkJDNUZNQ0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFJek9BL00xWmRGUElzd2VoWjFuemJ0VFNURG4KRHMyVnhSV0VnclFFYzNSYmV3a1NkbTlBS3MwVGR0ZHdEbnBEL2tRYkNyS2xEeFF3RWg3NFZNSFZYYkFadDdsVwpCSm90T21xdXgxYThKYklDRTljR0FHRzFvS0g5R29jWERZY0JzOTA3ckxIdStpVzFnL0xVdG5hN1dSampqZnBLCnFGelFmOGdJUHZIM09BZ3B1RVVncUx5QU8ya0VnelZwTjZwQVJxSnZVRks2TUQ0YzFmMnlxWGxwNXhrN2dFSnIKUzQ4WmF6d0RmWUVmV3Jrdld1YWdvZ1M2SktvbjVEZ0Z1ZHhINXM2Snl6R3lPVnZ0eG1TY2FvOHNxaCs3UXkybgoyLzFVcU5ZK0hlN0x4d04rYkhwYkIxNUtIMTU5ZHNuS3BRbjRORG1jSTZrVnJ3MDVJMUg5ZGRBbGF0bz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
+ export AIRSHIP_CONFIG_EPHEMERAL_IP=10.23.25.101
+ AIRSHIP_CONFIG_EPHEMERAL_IP=10.23.25.101
++ cat tools/deployment/certificates/airship_config_client_cert_data
++ base64 -w0
+ export AIRSHIP_CONFIG_CLIENT_CERT_DATA=LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQwRENDQXJnQ0ZFdFBveEZYSjVrVFNWTXQ0OVlqcHBQL3hCYnlNQTBHQ1NxR1NJYjNEUUVCQ3dVQU1CVXgKRXpBUkJnTlZCQU1UQ210MVltVnlibVYwWlhNd0hoY05NakF3TVRJME1Ua3hOVEV3V2hjTk1qa3hNakF5TVRreApOVEV3V2pBME1Sa3dGd1lEVlFRRERCQnJkV0psY201bGRHVnpMV0ZrYldsdU1SY3dGUVlEVlFRS0RBNXplWE4wClpXMDZiV0Z6ZEdWeWN6Q0NBaUl3RFFZSktvWklodmNOQVFFQkJRQURnZ0lQQURDQ0Fnb0NnZ0lCQU1iaFhUUmsKVjZiZXdsUjBhZlpBdTBGYWVsOXRtRThaSFEvaGtaSHhuTjc2bDZUUFltcGJvaDRvRjNGMFFqbzROS1o5NVRuWgo0OWNoV240eFJiZVlPU25EcDBpV0Qzd0pXUlZ5aVFvVUFyYTlNcHVPNkVFU1FpbFVGNXNxc0VXUVdVMjBETStBCkdxK1k0Z2c3eDJ1Q0hTdk1GUmkrNEw5RWlXR2xnRDIvb1hXUm5NWEswNExQajZPb3Vkb2Zid2RmT3J6dTBPVkUKUzR0eGtuS1BCY1BUU3YxMWVaWVhja0JEVjNPbExENEZ3dTB3NTcwcnczNzAraEpYdlZxd3Zjb2RjZjZEL1BXWQowamlnd2ppeUJuZ2dXYW04UVFjd1Nud3o0d05sV3hKOVMyWUJFb1ptdWxVUlFaWVk5ZXRBcEpBdFMzTjlUNlQ2ClovSlJRdEdhZDJmTldTYkxEck5qdU1OTGhBYWRMQnhJUHpBNXZWWk5aalJkdEMwU25pMlFUMTVpSFp4d1RxcjQKakRQQ0pYRXU3KytxcWpQVldUaUZLK3JqcVNhS1pqVWZVaUpHQkJWcm5RZkJENHNtRnNkTjB5cm9tYTZOYzRMNQpKS21RV1NHdmd1aG0zbW5sYjFRaVRZanVyZFJQRFNmdmwrQ0NHbnA1QkkvZ1pwMkF1SHMvNUpKVTJlc1ZvL0xsCkVPdHdSOXdXd3dXcTAvZjhXS3R4bVRrMTUyOUp2dFBGQXQweW1CVjhQbHZlYnVwYmJqeW5pL2xWbTJOYmV6dWUKeCtlMEpNbGtWWnFmYkRSS243SjZZSnJHWW1CUFV0QldoSVkzb1pJVTFEUXI4SUlIbkdmYlZoWlR5ME1IMkFCQQp1dlVQcUtSVk80UGkxRTF4OEE2eWVPeVRDcnB4L0pBazVyR2RBZ01CQUFFd0RRWUpLb1pJaHZjTkFRRUxCUUFECmdnRUJBSWNFM1BxZHZDTVBIMnJzMXJESk9ESHY3QWk4S01PVXZPRi90RjlqR2EvSFBJbkh3RlVFNEltbldQeDYKVUdBMlE1bjFsRDFGQlU0T0M4eElZc3VvS1VQVHk1T0t6SVNMNEZnL0lEcG54STlrTXlmNStMR043aG8rblJmawpCZkpJblVYb0tERW1neHZzSWFGd1h6bGtSTDJzL1lKYUZRRzE1Uis1YzFyckJmd2dJOFA5Tkd6aEM1cXhnSmovCm04K3hPMGhXUmJIYklrQ21NekRib2pCSWhaL00rb3VYR1doei9TakpodXhZTVBnek5MZkFGcy9PMTVaSjd3YXcKZ3ZoSGc3L2E5UzRvUCtEYytPa3VrMkV1MUZjL0E5WHpWMzc5aWhNWW5ub3RQMldWeFZ3b0ZZQUg0NUdQcDZsUApCQmwyNnkxc2JMbjl6aGZYUUJIMVpFN0EwZVE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
+ AIRSHIP_CONFIG_CLIENT_CERT_DATA=LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUQwRENDQXJnQ0ZFdFBveEZYSjVrVFNWTXQ0OVlqcHBQL3hCYnlNQTBHQ1NxR1NJYjNEUUVCQ3dVQU1CVXgKRXpBUkJnTlZCQU1UQ210MVltVnlibVYwWlhNd0hoY05NakF3TVRJME1Ua3hOVEV3V2hjTk1qa3hNakF5TVRreApOVEV3V2pBME1Sa3dGd1lEVlFRRERCQnJkV0psY201bGRHVnpMV0ZrYldsdU1SY3dGUVlEVlFRS0RBNXplWE4wClpXMDZiV0Z6ZEdWeWN6Q0NBaUl3RFFZSktvWklodmNOQVFFQkJRQURnZ0lQQURDQ0Fnb0NnZ0lCQU1iaFhUUmsKVjZiZXdsUjBhZlpBdTBGYWVsOXRtRThaSFEvaGtaSHhuTjc2bDZUUFltcGJvaDRvRjNGMFFqbzROS1o5NVRuWgo0OWNoV240eFJiZVlPU25EcDBpV0Qzd0pXUlZ5aVFvVUFyYTlNcHVPNkVFU1FpbFVGNXNxc0VXUVdVMjBETStBCkdxK1k0Z2c3eDJ1Q0hTdk1GUmkrNEw5RWlXR2xnRDIvb1hXUm5NWEswNExQajZPb3Vkb2Zid2RmT3J6dTBPVkUKUzR0eGtuS1BCY1BUU3YxMWVaWVhja0JEVjNPbExENEZ3dTB3NTcwcnczNzAraEpYdlZxd3Zjb2RjZjZEL1BXWQowamlnd2ppeUJuZ2dXYW04UVFjd1Nud3o0d05sV3hKOVMyWUJFb1ptdWxVUlFaWVk5ZXRBcEpBdFMzTjlUNlQ2ClovSlJRdEdhZDJmTldTYkxEck5qdU1OTGhBYWRMQnhJUHpBNXZWWk5aalJkdEMwU25pMlFUMTVpSFp4d1RxcjQKakRQQ0pYRXU3KytxcWpQVldUaUZLK3JqcVNhS1pqVWZVaUpHQkJWcm5RZkJENHNtRnNkTjB5cm9tYTZOYzRMNQpKS21RV1NHdmd1aG0zbW5sYjFRaVRZanVyZFJQRFNmdmwrQ0NHbnA1QkkvZ1pwMkF1SHMvNUpKVTJlc1ZvL0xsCkVPdHdSOXdXd3dXcTAvZjhXS3R4bVRrMTUyOUp2dFBGQXQweW1CVjhQbHZlYnVwYmJqeW5pL2xWbTJOYmV6dWUKeCtlMEpNbGtWWnFmYkRSS243SjZZSnJHWW1CUFV0QldoSVkzb1pJVTFEUXI4SUlIbkdmYlZoWlR5ME1IMkFCQQp1dlVQcUtSVk80UGkxRTF4OEE2eWVPeVRDcnB4L0pBazVyR2RBZ01CQUFFd0RRWUpLb1pJaHZjTkFRRUxCUUFECmdnRUJBSWNFM1BxZHZDTVBIMnJzMXJESk9ESHY3QWk4S01PVXZPRi90RjlqR2EvSFBJbkh3RlVFNEltbldQeDYKVUdBMlE1bjFsRDFGQlU0T0M4eElZc3VvS1VQVHk1T0t6SVNMNEZnL0lEcG54STlrTXlmNStMR043aG8rblJmawpCZkpJblVYb0tERW1neHZzSWFGd1h6bGtSTDJzL1lKYUZRRzE1Uis1YzFyckJmd2dJOFA5Tkd6aEM1cXhnSmovCm04K3hPMGhXUmJIYklrQ21NekRib2pCSWhaL00rb3VYR1doei9TakpodXhZTVBnek5MZkFGcy9PMTVaSjd3YXcKZ3ZoSGc3L2E5UzRvUCtEYytPa3VrMkV1MUZjL0E5WHpWMzc5aWhNWW5ub3RQMldWeFZ3b0ZZQUg0NUdQcDZsUApCQmwyNnkxc2JMbjl6aGZYUUJIMVpFN0EwZVE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
++ cat tools/deployment/certificates/airship_config_client_key_data
++ base64 -w0
+ export AIRSHIP_CONFIG_CLIENT_KEY_DATA=LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlKS1FJQkFBS0NBZ0VBeHVGZE5HUlhwdDdDVkhScDlrQzdRVnA2WDIyWVR4a2REK0dSa2ZHYzN2cVhwTTlpCmFsdWlIaWdYY1hSQ09qZzBwbjNsT2RuajF5RmFmakZGdDVnNUtjT25TSllQZkFsWkZYS0pDaFFDdHIweW00N28KUVJKQ0tWUVhteXF3UlpCWlRiUU16NEFhcjVqaUNEdkhhNElkSzh3VkdMN2d2MFNKWWFXQVBiK2hkWkdjeGNyVApncytQbzZpNTJoOXZCMTg2dk83UTVVUkxpM0dTY284Rnc5TksvWFY1bGhkeVFFTlhjNlVzUGdYQzdURG52U3ZECmZ2VDZFbGU5V3JDOXloMXgvb1A4OVpqU09LRENPTElHZUNCWnFieEJCekJLZkRQakEyVmJFbjFMWmdFU2htYTYKVlJGQmxoajE2MENra0MxTGMzMVBwUHBuOGxGQzBacDNaODFaSnNzT3MyTzR3MHVFQnAwc0hFZy9NRG05VmsxbQpORjIwTFJLZUxaQlBYbUlkbkhCT3F2aU1NOElsY1M3djc2cXFNOVZaT0lVcjZ1T3BKb3BtTlI5U0lrWUVGV3VkCkI4RVBpeVlXeDAzVEt1aVpybzF6Z3Zra3FaQlpJYStDNkdiZWFlVnZWQ0pOaU82dDFFOE5KKytYNElJYWVua0UKaitCbW5ZQzRlei9ra2xUWjZ4V2o4dVVRNjNCSDNCYkRCYXJUOS94WXEzR1pPVFhuYjBtKzA4VUMzVEtZRlh3KwpXOTV1Nmx0dVBLZUwrVldiWTF0N081N0g1N1FreVdSVm1wOXNORXFmc25wZ21zWmlZRTlTMEZhRWhqZWhraFRVCk5DdndnZ2VjWjl0V0ZsUExRd2ZZQUVDNjlRK29wRlU3ZytMVVRYSHdEcko0N0pNS3VuSDhrQ1Rtc1owQ0F3RUEKQVFLQ0FnQUJ2U1N3ZVpRZW5HSDhsUXY4SURMQzdvU1ZZd0xxNWlCUDdEdjJsN00wYStKNWlXcWwzV2s4ZEVOSQpOYWtDazAwNmkyMCtwVDROdW5mdEZJYzBoTHN6TjBlMkpjRzY1dVlGZnZ2ZHY3RUtZZnNZU3hhU3d4TWJBMlkxCmNCa2NjcGVsUzBhMVpieFYvck16T1RxVUlRNGFQTzJPU3RUeU55b3dWVjhhcXh0QlNPV2pBUlA2VjlBOHNSUDIKNlVGeVFnM2thdjRla3d0S0M5TW85MEVvcGlkSXNnYy9IYk5kQm5tMFJDUnY0bU1DNmVPTXp0NGx0UVNldG0rcwpaRkUwZkM5cjkwRjE4RUVlUjZHTEYxdGhIMzlKTWFFcjYrc3F6TlZXU1VPVGxNN2M5SE55QTJIcnJudnhVUVNOCmF3SkZWSEFOY1hJSjBqcW9icmR6MTdMbGtIRVFGczNLdjRlcDR3REJKMlF0eisxdUFvY1JoV3ZSaWJxWEQ3THgKVmpPdGRyT1h3ZFQxY2ZrKzZRc1RMWUFKR3ptdDdsY1M2QjNnYzJHWmNJWGwyNVlqTUQ1ZVhpa1dEc3hYWmt1UAorb3MzVGhxeGZIS25ITmxtYk9SSVpDMW92Q1NkSTRWZVpzalk0MUs5K0dNaXdXSk1kektpRkp3NlR2blRSUldTCkxod2EzUTlBVmMvTEg0SC9PbU9qWDc0QTNZSWwrRDFVUHd3VzAvMmw4S3BNM0VWZ21XalJMV1ZIRnBNTGJNSlcKZVZKd3dKUmF3bWZLdHZ6bU9KRHlhTXJJblhqTDMvSE1EaWtwU3JhRzFyTnc1SUozOXJZdEFIUUQ1L1VuZlRkSApLNXVjakVucTdPdDMyR1ozcHJvRTU1ZGFBY0hQbktuOGpYZ1ZKTUQyOWh5cEZvL2ZRUUtDQVFFQStBbjRoSDFFCm9GK3FlcWlvYXR3N2cwaVdQUDNCeklxOEZWbWtsRlZBYVF5U28wU2QxWFBybmErR0RFQVd0cHlsVjF5ZkZkR2oKSHc4YXU5NnpUZnRuNWZCRkQxWG1NTkNZeTcrM293V3ArK1NwYUMvMTYzN1dvb3lLRjBjVFNvcWEzZEVuRUtSSwp4TGF2a0lFUTI3OXRBNFVUK0dVK3pTb0NPUFBNNE1JS3poR0FDczZ1anRySzFNcXpwK0JhYldzRlBuN2J1bStVCkRHSFIrNCtab2tBL1Q2N2luYlRxZUwwVzJCNjRMckFURHpZL3Y4NlRGbW1aallEaHRKR1JIWVZUOU9XSXR0RVkKNnZtUDN0a1dOTWt0R2w4bTFiQ0FHQ1JlcGtycUhxWXNMWG5GQ2ZZSFFtOXNpaGgvM3JFVjZ1MUYxZCt0U3JFMgprU1ZVOHhVWDUwbHFNUUtDQVFFQXpVTjZaS0lRNldkT09FR3ZyMExRL1hVczI0bUczN3lGMjhJUDJEcWFBWWVzCnJza2xTdjdlSU9TZWV3MW1CRHVCRkl2bkZvcTVsRlA3cXhWcEIyWjNNSGlDMVNaclZSZjlQTjdCNGFzcmNyMCsKdDB2S0NXWFFIaTVQQXhucXdYb2E2N0Q1bnkwdnlvV0lVUXAyZEZMdkIwQmp0b3MvajJFaHpJZk5WMm1UOW15bgpWQXZOWEdtZnc4SVJCL1diMGkzQ3c0Wityb1l1dTJkRHo2UUwzUFVvN1hLS3ljZzR1UzU1eksvcWZPc09lYm5mCnpsd3ZqbGxNSitmVFFHNzMrQnpINE5IWGs2akZZQzU4eXBrdXd0cmJmYk1pSkZOWThyV1ptL01Nd1VDWlZDQ3kKeUlxQ3FHQVB6b2kyU05zSEtaTlJqN3ZZQ3dQQVd6TzFidjFGcC9hM0xRS0NBUUVBeG0zTGw4cFROVzF6QjgrWApkRzJkV3FpZU1FcmRXRklBcDUvZ1R4NW9lZUdxQ2QxaDJ4cHlldUtwZlhGaitsRVU0Ty9qQU9TRjk5bndqQzFjCkNsMit2Ni9ZdjZ6N2l6L0ZqUEpoNlpRbGFiT0RaeXMvTkZkelEvVGtvRHluRFRJWE5LOFc3blJRc0ZCcDRWT3YKZGUwTlBBeWhiazBvMFo3eXlqY1lSeEpVN0lnSmhCdldmOGcvRGI3ZnZNUjU4eUR6d0F4aW9pS1RNTmlzMFBBUAplMEtrbzQySUU1eGhHNWhDQjBHRUhTMlZBYzFuY0gzRkk5LzFETVAzVEtwTGltOVlQQW5JdG1CTzYrUWNtYTNYCjJ3QzZDV2ZudkhvSDc4aGd3KzRZbjg1V2QwYjhQN3pJRC9qdHZ3aGNlMzMxeDh4cjJ1Nm5ScUxBd1pzNCs0SjcKYmZkSWNRS0NBUUFDL2JlNzNheTNhZnoyenVZN2ZKTEZEcjhQbCtweU9qSU5LTC9JVzlwQXFYUjN1NUNpamlJNApnbnhZdUxKQzM0Y2JBSXJtaGpEOEcxa3dmZ2hneGpwNFoxa290LzJhYU5ZVTIvNGhScmhFWE1PY01pdUloWVpKCjJrem1jNnM3RklkdDVjOU5aWUFyeUZSYk1mYlY3UnQwbEppZllWb1V3Y3FYUzJkUG5jYzlNUW9qTEdUYXN1TlUKRy9EWmw5ZWtjV3hFSXlLWGNuY2QzZnhiK3p6OUJFbUxaRDduZjlacnhHU2IrZmhGeDdzWFJRRWc1YkQvdHdkbwpFWFcvbTU1YmJEZnhhNzFqZG5NaDJxdVEzRGlWT0ZFNGZMTERxcjlDRWlsaDMySFJNeHJJNGcwWTVRUFFaazMwCnFZTldmbktWUllOTHYrWC9DeGZ6ZkVacGpxRkVPRkVsQW9JQkFRQ0t6R2JGdmx6d1BaUmh4czd2VXYxOXlIUXAKQzFmR3gwb0tpRDFSNWZwWVBrT0VRQWVudEFKRHNyYVRsNy9rSDY5V09VbUQ1T3gxbWpyRFB0a1M4WnhXYlJXeApGYjJLK3JxYzRtcGFacGROV09OTkszK3RNZmsrb0FRcWUySU1JV253NUhmbVpjNE1QY0t0bkZQYlJTTkF0aktwCkQ2aG9oL3BXMmdjRFA0cVpNWVZvRW04MVZYZEZDUGhOYitNYnUvU3gyaFB4U0dXYTVGaTczeEtwWWp5M3BISlQKWFoyY2lHN0VNQ3NKZW9HS2FRdmNCY1kvNGlSRGFoV0hWcmlsSVhJQXJQdXdmVUIybzZCZFR0allHeU5sZ2NmeApxWEt4aXBTaEE2VlNienVnR3pkdEdNeEUyekRHVEkxOXFSQy96OUNEREM1ZTJTQUZqbEJUV0QyUHJjcU4KLS0tLS1FTkQgUlNBIFBSSVZBVEUgS0VZLS0tLS0K
+ AIRSHIP_CONFIG_CLIENT_KEY_DATA=LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlKS1FJQkFBS0NBZ0VBeHVGZE5HUlhwdDdDVkhScDlrQzdRVnA2WDIyWVR4a2REK0dSa2ZHYzN2cVhwTTlpCmFsdWlIaWdYY1hSQ09qZzBwbjNsT2RuajF5RmFmakZGdDVnNUtjT25TSllQZkFsWkZYS0pDaFFDdHIweW00N28KUVJKQ0tWUVhteXF3UlpCWlRiUU16NEFhcjVqaUNEdkhhNElkSzh3VkdMN2d2MFNKWWFXQVBiK2hkWkdjeGNyVApncytQbzZpNTJoOXZCMTg2dk83UTVVUkxpM0dTY284Rnc5TksvWFY1bGhkeVFFTlhjNlVzUGdYQzdURG52U3ZECmZ2VDZFbGU5V3JDOXloMXgvb1A4OVpqU09LRENPTElHZUNCWnFieEJCekJLZkRQakEyVmJFbjFMWmdFU2htYTYKVlJGQmxoajE2MENra0MxTGMzMVBwUHBuOGxGQzBacDNaODFaSnNzT3MyTzR3MHVFQnAwc0hFZy9NRG05VmsxbQpORjIwTFJLZUxaQlBYbUlkbkhCT3F2aU1NOElsY1M3djc2cXFNOVZaT0lVcjZ1T3BKb3BtTlI5U0lrWUVGV3VkCkI4RVBpeVlXeDAzVEt1aVpybzF6Z3Zra3FaQlpJYStDNkdiZWFlVnZWQ0pOaU82dDFFOE5KKytYNElJYWVua0UKaitCbW5ZQzRlei9ra2xUWjZ4V2o4dVVRNjNCSDNCYkRCYXJUOS94WXEzR1pPVFhuYjBtKzA4VUMzVEtZRlh3KwpXOTV1Nmx0dVBLZUwrVldiWTF0N081N0g1N1FreVdSVm1wOXNORXFmc25wZ21zWmlZRTlTMEZhRWhqZWhraFRVCk5DdndnZ2VjWjl0V0ZsUExRd2ZZQUVDNjlRK29wRlU3ZytMVVRYSHdEcko0N0pNS3VuSDhrQ1Rtc1owQ0F3RUEKQVFLQ0FnQUJ2U1N3ZVpRZW5HSDhsUXY4SURMQzdvU1ZZd0xxNWlCUDdEdjJsN00wYStKNWlXcWwzV2s4ZEVOSQpOYWtDazAwNmkyMCtwVDROdW5mdEZJYzBoTHN6TjBlMkpjRzY1dVlGZnZ2ZHY3RUtZZnNZU3hhU3d4TWJBMlkxCmNCa2NjcGVsUzBhMVpieFYvck16T1RxVUlRNGFQTzJPU3RUeU55b3dWVjhhcXh0QlNPV2pBUlA2VjlBOHNSUDIKNlVGeVFnM2thdjRla3d0S0M5TW85MEVvcGlkSXNnYy9IYk5kQm5tMFJDUnY0bU1DNmVPTXp0NGx0UVNldG0rcwpaRkUwZkM5cjkwRjE4RUVlUjZHTEYxdGhIMzlKTWFFcjYrc3F6TlZXU1VPVGxNN2M5SE55QTJIcnJudnhVUVNOCmF3SkZWSEFOY1hJSjBqcW9icmR6MTdMbGtIRVFGczNLdjRlcDR3REJKMlF0eisxdUFvY1JoV3ZSaWJxWEQ3THgKVmpPdGRyT1h3ZFQxY2ZrKzZRc1RMWUFKR3ptdDdsY1M2QjNnYzJHWmNJWGwyNVlqTUQ1ZVhpa1dEc3hYWmt1UAorb3MzVGhxeGZIS25ITmxtYk9SSVpDMW92Q1NkSTRWZVpzalk0MUs5K0dNaXdXSk1kektpRkp3NlR2blRSUldTCkxod2EzUTlBVmMvTEg0SC9PbU9qWDc0QTNZSWwrRDFVUHd3VzAvMmw4S3BNM0VWZ21XalJMV1ZIRnBNTGJNSlcKZVZKd3dKUmF3bWZLdHZ6bU9KRHlhTXJJblhqTDMvSE1EaWtwU3JhRzFyTnc1SUozOXJZdEFIUUQ1L1VuZlRkSApLNXVjakVucTdPdDMyR1ozcHJvRTU1ZGFBY0hQbktuOGpYZ1ZKTUQyOWh5cEZvL2ZRUUtDQVFFQStBbjRoSDFFCm9GK3FlcWlvYXR3N2cwaVdQUDNCeklxOEZWbWtsRlZBYVF5U28wU2QxWFBybmErR0RFQVd0cHlsVjF5ZkZkR2oKSHc4YXU5NnpUZnRuNWZCRkQxWG1NTkNZeTcrM293V3ArK1NwYUMvMTYzN1dvb3lLRjBjVFNvcWEzZEVuRUtSSwp4TGF2a0lFUTI3OXRBNFVUK0dVK3pTb0NPUFBNNE1JS3poR0FDczZ1anRySzFNcXpwK0JhYldzRlBuN2J1bStVCkRHSFIrNCtab2tBL1Q2N2luYlRxZUwwVzJCNjRMckFURHpZL3Y4NlRGbW1aallEaHRKR1JIWVZUOU9XSXR0RVkKNnZtUDN0a1dOTWt0R2w4bTFiQ0FHQ1JlcGtycUhxWXNMWG5GQ2ZZSFFtOXNpaGgvM3JFVjZ1MUYxZCt0U3JFMgprU1ZVOHhVWDUwbHFNUUtDQVFFQXpVTjZaS0lRNldkT09FR3ZyMExRL1hVczI0bUczN3lGMjhJUDJEcWFBWWVzCnJza2xTdjdlSU9TZWV3MW1CRHVCRkl2bkZvcTVsRlA3cXhWcEIyWjNNSGlDMVNaclZSZjlQTjdCNGFzcmNyMCsKdDB2S0NXWFFIaTVQQXhucXdYb2E2N0Q1bnkwdnlvV0lVUXAyZEZMdkIwQmp0b3MvajJFaHpJZk5WMm1UOW15bgpWQXZOWEdtZnc4SVJCL1diMGkzQ3c0Wityb1l1dTJkRHo2UUwzUFVvN1hLS3ljZzR1UzU1eksvcWZPc09lYm5mCnpsd3ZqbGxNSitmVFFHNzMrQnpINE5IWGs2akZZQzU4eXBrdXd0cmJmYk1pSkZOWThyV1ptL01Nd1VDWlZDQ3kKeUlxQ3FHQVB6b2kyU05zSEtaTlJqN3ZZQ3dQQVd6TzFidjFGcC9hM0xRS0NBUUVBeG0zTGw4cFROVzF6QjgrWApkRzJkV3FpZU1FcmRXRklBcDUvZ1R4NW9lZUdxQ2QxaDJ4cHlldUtwZlhGaitsRVU0Ty9qQU9TRjk5bndqQzFjCkNsMit2Ni9ZdjZ6N2l6L0ZqUEpoNlpRbGFiT0RaeXMvTkZkelEvVGtvRHluRFRJWE5LOFc3blJRc0ZCcDRWT3YKZGUwTlBBeWhiazBvMFo3eXlqY1lSeEpVN0lnSmhCdldmOGcvRGI3ZnZNUjU4eUR6d0F4aW9pS1RNTmlzMFBBUAplMEtrbzQySUU1eGhHNWhDQjBHRUhTMlZBYzFuY0gzRkk5LzFETVAzVEtwTGltOVlQQW5JdG1CTzYrUWNtYTNYCjJ3QzZDV2ZudkhvSDc4aGd3KzRZbjg1V2QwYjhQN3pJRC9qdHZ3aGNlMzMxeDh4cjJ1Nm5ScUxBd1pzNCs0SjcKYmZkSWNRS0NBUUFDL2JlNzNheTNhZnoyenVZN2ZKTEZEcjhQbCtweU9qSU5LTC9JVzlwQXFYUjN1NUNpamlJNApnbnhZdUxKQzM0Y2JBSXJtaGpEOEcxa3dmZ2hneGpwNFoxa290LzJhYU5ZVTIvNGhScmhFWE1PY01pdUloWVpKCjJrem1jNnM3RklkdDVjOU5aWUFyeUZSYk1mYlY3UnQwbEppZllWb1V3Y3FYUzJkUG5jYzlNUW9qTEdUYXN1TlUKRy9EWmw5ZWtjV3hFSXlLWGNuY2QzZnhiK3p6OUJFbUxaRDduZjlacnhHU2IrZmhGeDdzWFJRRWc1YkQvdHdkbwpFWFcvbTU1YmJEZnhhNzFqZG5NaDJxdVEzRGlWT0ZFNGZMTERxcjlDRWlsaDMySFJNeHJJNGcwWTVRUFFaazMwCnFZTldmbktWUllOTHYrWC9DeGZ6ZkVacGpxRkVPRkVsQW9JQkFRQ0t6R2JGdmx6d1BaUmh4czd2VXYxOXlIUXAKQzFmR3gwb0tpRDFSNWZwWVBrT0VRQWVudEFKRHNyYVRsNy9rSDY5V09VbUQ1T3gxbWpyRFB0a1M4WnhXYlJXeApGYjJLK3JxYzRtcGFacGROV09OTkszK3RNZmsrb0FRcWUySU1JV253NUhmbVpjNE1QY0t0bkZQYlJTTkF0aktwCkQ2aG9oL3BXMmdjRFA0cVpNWVZvRW04MVZYZEZDUGhOYitNYnUvU3gyaFB4U0dXYTVGaTczeEtwWWp5M3BISlQKWFoyY2lHN0VNQ3NKZW9HS2FRdmNCY1kvNGlSRGFoV0hWcmlsSVhJQXJQdXdmVUIybzZCZFR0allHeU5sZ2NmeApxWEt4aXBTaEE2VlNienVnR3pkdEdNeEUyekRHVEkxOXFSQy96OUNEREM1ZTJTQUZqbEJUV0QyUHJjcU4KLS0tLS1FTkQgUlNBIFBSSVZBVEUgS0VZLS0tLS0K
+ rm -rf /home/rishabh/.airship
+ mkdir -p /home/rishabh/.airship
+ cp -rp /home/rishabh/.kube/config /home/rishabh/.airship/kubeconfig
+ echo 'Generate ~/.airship/config'
Generate ~/.airship/config
+ envsubst
```

`$ ./tools/deployment/docker/41_initialize_management_cluster.sh`

```
+ echo 'Execute Local Overrides'
Execute Local Overrides
+ rm -rf /home/rishabh/.cluster-api
+ export AIRSHIPCTL_WS=/home/zuul/src/opendev.org/airship/airshipctl
+ AIRSHIPCTL_WS=/home/zuul/src/opendev.org/airship/airshipctl
+ cd /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/capd
+ ./docker-overrides.py
airshipctl local overrides generated from local repository for docker provider airshipctl/manifests/function/capd/v0.3.0
in order to use them, please run:

airshipctl cluster init --debug
+ echo 'Created Local Overrides'
Created Local Overrides
+ export KUBECONFIG=/home/rishabh/.airship/kubeconfig
+ KUBECONFIG=/home/rishabh/.airship/kubeconfig
+ echo 'Initialize Managment Cluster with CAPI and CAPD Components'
Initialize Managment Cluster with CAPI and CAPD Components
+ airshipctl cluster init --debug
[airshipctl] 2020/07/13 12:54:12 Starting cluster-api initiation
Installing the clusterctl inventory CRD
Creating CustomResourceDefinition="providers.clusterctl.cluster.x-k8s.io"
Fetching providers
[airshipctl] 2020/07/13 12:54:13 Creating arishipctl repository implementation interface for provider cluster-api of type CoreProvider
[airshipctl] 2020/07/13 12:54:13 Setting up airshipctl provider Components client
Provider type: CoreProvider, name: cluster-api
[airshipctl] 2020/07/13 12:54:13 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: CoreProvider, name: cluster-api
Fetching File="components.yaml" Provider="cluster-api" Version="v0.3.3"
[airshipctl] 2020/07/13 12:54:13 Building cluster-api provider component documents from kustomize path at /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/capi/v0.3.3
[airshipctl] 2020/07/13 12:54:13 Creating arishipctl repository implementation interface for provider kubeadm of type BootstrapProvider
[airshipctl] 2020/07/13 12:54:13 Setting up airshipctl provider Components client
Provider type: BootstrapProvider, name: kubeadm
[airshipctl] 2020/07/13 12:54:13 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: BootstrapProvider, name: kubeadm
Fetching File="components.yaml" Provider="bootstrap-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/13 12:54:13 Building cluster-api provider component documents from kustomize path at /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/cabpk/v0.3.3
[airshipctl] 2020/07/13 12:54:14 Creating arishipctl repository implementation interface for provider kubeadm of type ControlPlaneProvider
[airshipctl] 2020/07/13 12:54:14 Setting up airshipctl provider Components client
Provider type: ControlPlaneProvider, name: kubeadm
[airshipctl] 2020/07/13 12:54:14 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: ControlPlaneProvider, name: kubeadm
Fetching File="components.yaml" Provider="control-plane-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/13 12:54:14 Building cluster-api provider component documents from kustomize path at /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/cacpk/v0.3.3
[airshipctl] 2020/07/13 12:54:14 Creating arishipctl repository implementation interface for provider docker of type InfrastructureProvider
[airshipctl] 2020/07/13 12:54:14 Setting up airshipctl provider Components client
Provider type: InfrastructureProvider, name: docker
[airshipctl] 2020/07/13 12:54:14 Getting airshipctl provider components, setting skipping variable substitution.
Provider type: InfrastructureProvider, name: docker
Fetching File="components.yaml" Provider="infrastructure-docker" Version="v0.3.0"
[airshipctl] 2020/07/13 12:54:14 Building cluster-api provider component documents from kustomize path at /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/capd/v0.3.0
[airshipctl] 2020/07/13 12:54:14 Creating arishipctl repository implementation interface for provider cluster-api of type CoreProvider
Fetching File="metadata.yaml" Provider="cluster-api" Version="v0.3.3"
[airshipctl] 2020/07/13 12:54:14 Building cluster-api provider component documents from kustomize path at /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/capi/v0.3.3
[airshipctl] 2020/07/13 12:54:15 Creating arishipctl repository implementation interface for provider kubeadm of type BootstrapProvider
Fetching File="metadata.yaml" Provider="bootstrap-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/13 12:54:15 Building cluster-api provider component documents from kustomize path at /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/cabpk/v0.3.3
[airshipctl] 2020/07/13 12:54:15 Creating arishipctl repository implementation interface for provider kubeadm of type ControlPlaneProvider
Fetching File="metadata.yaml" Provider="control-plane-kubeadm" Version="v0.3.3"
[airshipctl] 2020/07/13 12:54:15 Building cluster-api provider component documents from kustomize path at /home/zuul/src/opendev.org/airship/airshipctl/manifests/function/cacpk/v0.3.3
[airshipctl] 2020/07/13 12:54:15 Creating arishipctl repository implementation interface for provider docker of type InfrastructureProvider
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
+ echo 'Waiting for all pods to come up'
Waiting for all pods to come up
+ kubectl --kubeconfig /home/rishabh/.airship/kubeconfig wait --for=condition=ready pods --all --timeout=1000s -A
pod/capd-controller-manager-75f5d546d7-vzl6m condition met
pod/capi-kubeadm-bootstrap-controller-manager-5bb9bfdc46-6l58t condition met
pod/capi-kubeadm-control-plane-controller-manager-77466c7666-fm54s condition met
pod/capi-controller-manager-5798474d9f-sn5vx condition met
pod/capi-controller-manager-5d64dd9dfb-th4sq condition met
pod/capi-kubeadm-bootstrap-controller-manager-7c78fff45-q7j86 condition met
pod/capi-kubeadm-control-plane-controller-manager-58465bb88f-x9jh9 condition met
pod/cert-manager-69b4f77ffc-jzzcw condition met
pod/cert-manager-cainjector-576978ffc8-p822t condition met
pod/cert-manager-webhook-c67fbc858-gxk7l condition met
pod/coredns-6955765f44-52n5z condition met
pod/coredns-6955765f44-q54q7 condition met
pod/etcd-capi-docker-control-plane condition met
pod/kindnet-jqjpx condition met
pod/kube-apiserver-capi-docker-control-plane condition met
pod/kube-controller-manager-capi-docker-control-plane condition met
pod/kube-proxy-vg5x6 condition met
pod/kube-scheduler-capi-docker-control-plane condition met
pod/local-path-provisioner-7745554f7f-w8glm condition met
+ kubectl --kubeconfig /home/rishabh/.airship/kubeconfig get pods -A
NAMESPACE                           NAME                                                             READY   STATUS    RESTARTS   AGE
capd-system                         capd-controller-manager-75f5d546d7-vzl6m                         2/2     Running   1          32s
capi-kubeadm-bootstrap-system       capi-kubeadm-bootstrap-controller-manager-5bb9bfdc46-6l58t       2/2     Running   0          42s
capi-kubeadm-control-plane-system   capi-kubeadm-control-plane-controller-manager-77466c7666-fm54s   2/2     Running   0          37s
capi-system                         capi-controller-manager-5798474d9f-sn5vx                         2/2     Running   0          47s
capi-webhook-system                 capi-controller-manager-5d64dd9dfb-th4sq                         2/2     Running   0          49s
capi-webhook-system                 capi-kubeadm-bootstrap-controller-manager-7c78fff45-q7j86        2/2     Running   0          45s
capi-webhook-system                 capi-kubeadm-control-plane-controller-manager-58465bb88f-x9jh9   2/2     Running   0          40s
cert-manager                        cert-manager-69b4f77ffc-jzzcw                                    1/1     Running   0          73s
cert-manager                        cert-manager-cainjector-576978ffc8-p822t                         1/1     Running   0          73s
cert-manager                        cert-manager-webhook-c67fbc858-gxk7l                             1/1     Running   0          73s
kube-system                         coredns-6955765f44-52n5z                                         1/1     Running   0          4m19s
kube-system                         coredns-6955765f44-q54q7                                         1/1     Running   0          4m19s
kube-system                         etcd-capi-docker-control-plane                                   1/1     Running   0          4m29s
kube-system                         kindnet-jqjpx                                                    1/1     Running   0          4m19s
kube-system                         kube-apiserver-capi-docker-control-plane                         1/1     Running   0          4m29s
kube-system                         kube-controller-manager-capi-docker-control-plane                1/1     Running   0          4m29s
kube-system                         kube-proxy-vg5x6                                                 1/1     Running   0          4m19s
kube-system                         kube-scheduler-capi-docker-control-plane                         1/1     Running   0          4m29s
local-path-storage                  local-path-provisioner-7745554f7f-w8glm                          1/1     Running   0          4m19s
```

`$ ./tools/deployment/docker/51_deploy_workload_cluster.sh`

```
Deploy Target Workload Cluster
kubeadmconfigtemplate.bootstrap.cluster.x-k8s.io/dtc-md-0 created
cluster.cluster.x-k8s.io/dtc created
machinedeployment.cluster.x-k8s.io/dtc-md-0 created
machinehealthcheck.cluster.x-k8s.io/dtc-mhc-0 created
kubeadmcontrolplane.controlplane.cluster.x-k8s.io/dtc-control-plane created
dockercluster.infrastructure.cluster.x-k8s.io/dtc created
dockermachinetemplate.infrastructure.cluster.x-k8s.io/dtc-control-plane created
dockermachinetemplate.infrastructure.cluster.x-k8s.io/dtc-md-0 created
Get kubeconfig from secret
Error from server (NotFound): secrets "dtc-kubeconfig" not found
1: Retry to get kubeconfig from secret.
Generate kubeconfig
Generate kubeconfig: /tmp/dtc.kubeconfig
Wait for kubernetes cluster to be up
Unable to connect to the server: EOF
1: Retry to get kubectl version.
Check nodes status
node/dtc-dtc-control-plane-rqsjh condition met
NAME                           STATUS   ROLES    AGE   VERSION
dtc-dtc-control-plane-rqsjh    Ready    master   48s   v1.17.0
dtc-dtc-md-0-94c79cf9c-6c8j7   Ready    <none>   27s   v1.17.0
Waiting for all pods to come up
pod/calico-kube-controllers-65c8dd596b-tkbn7 condition met
pod/calico-node-pdp84 condition met
pod/calico-node-t5f68 condition met
pod/coredns-6955765f44-kh8k9 condition met
pod/coredns-6955765f44-nhklv condition met
pod/etcd-dtc-dtc-control-plane-rqsjh condition met
pod/kube-apiserver-dtc-dtc-control-plane-rqsjh condition met
pod/kube-controller-manager-dtc-dtc-control-plane-rqsjh condition met
pod/kube-proxy-9dvbp condition met
pod/kube-proxy-kkd4p condition met
pod/kube-scheduler-dtc-dtc-control-plane-rqsjh condition met
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-65c8dd596b-tkbn7              1/1     Running   0          78s
kube-system   calico-node-pdp84                                     1/1     Running   0          78s
kube-system   calico-node-t5f68                                     1/1     Running   0          70s
kube-system   coredns-6955765f44-kh8k9                              1/1     Running   0          78s
kube-system   coredns-6955765f44-nhklv                              1/1     Running   0          78s
kube-system   etcd-dtc-dtc-control-plane-rqsjh                      1/1     Running   0          84s
kube-system   kube-apiserver-dtc-dtc-control-plane-rqsjh            1/1     Running   0          84s
kube-system   kube-controller-manager-dtc-dtc-control-plane-rqsjh   1/1     Running   0          84s
kube-system   kube-proxy-9dvbp                                      1/1     Running   0          78s
kube-system   kube-proxy-kkd4p                                      1/1     Running   0          70s
kube-system   kube-scheduler-dtc-dtc-control-plane-rqsjh            1/1     Running   0          84s
Get cluster state
NAME   PHASE
dtc    Provisioned
```

## See Also

### Airshipctl And Cluster API Docker Integration

* [Airshipctl And Cluster API Docker Integration](../README.md)