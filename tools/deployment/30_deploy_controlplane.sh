#!/usr/bin/env bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

TARGET_IMAGE_DIR="/srv/iso"
EPHEMERAL_DOMAIN_NAME="air-ephemeral"
TARGET_IMAGE_URL="https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img"

# TODO (dukov) this is needed due to sushy tools inserts cdrom image to
# all vms. This can be removed once sushy tool is fixed
echo "Ensure all cdrom images are ejected."
for vm in $(sudo virsh list --all --name |grep -v ${EPHEMERAL_DOMAIN_NAME})
do
  sudo virsh domblklist $vm |
    awk 'NF==2 {print $1}' |
    grep -v Target |
    xargs -I{} sudo virsh change-media $vm {} --eject || :
done

echo "Download target image"
DOWNLOAD="200"
if [ -e ${TARGET_IMAGE_DIR}/target-image.qcow2 ]
then
    MTIME=$(date -d @$(stat -c %Y ${TARGET_IMAGE_DIR}/target-image.qcow2) +"%a, %d %b %Y %T %Z")
    DOWNLOAD=$(curl -sSLI \
        --write-out '%{http_code}' \
        -H "If-Modified-Since: ${MTIME}" \
        ${TARGET_IMAGE_URL} | tail -1)
fi
if [ "${DOWNLOAD}" != "304" ]
then
    curl -sSLo ${TARGET_IMAGE_DIR}/target-image.qcow2 ${TARGET_IMAGE_URL}
fi
md5sum /srv/iso/target-image.qcow2 | cut -d ' ' -f 1 > ${TARGET_IMAGE_DIR}/target-image.qcow2.md5sum

echo "Create target k8s cluster resources"
airshipctl phase apply controlplane

echo "Get kubeconfig from secret"
KUBECONFIG=""
N=0
MAX_RETRY=6
DELAY=10
until [ "$N" -ge ${MAX_RETRY} ]
do
  KUBECONFIG=$(kubectl --request-timeout 10s --kubeconfig ${HOME}/.airship/kubeconfig \
               get secret target-cluster-kubeconfig -o jsonpath='{.data.value}' || true)

  if [[ ! -z "$KUBECONFIG" ]]; then
      break
  fi

  N=$((N+1))
  echo "$N: Retry to get kubeconfig from secret."
  sleep ${DELAY}
done

if [[ -z "$KUBECONFIG" ]]; then
  echo "Could not get kubeconfig from sceret."
  exit 1
fi

echo "Create kubeconfig"
echo ${KUBECONFIG} | base64 -d > /tmp/targetkubeconfig

echo "Check kubectl version"
VERSION=""
N=0
MAX_RETRY=30
DELAY=60
until [ "$N" -ge ${MAX_RETRY} ]
do
  VERSION=$(timeout 20 kubectl --kubeconfig /tmp/targetkubeconfig version | grep 'Server Version' || true)

  if [[ ! -z "$VERSION" ]]; then
      break
  fi

  N=$((N+1))
  echo "$N: Retry to get kubectl version."
  sleep ${DELAY}
done

if [[ -z "$VERSION" ]]; then
  echo "Could not get kubectl version."
  exit 1
fi

echo "Check nodes status"
kubectl --kubeconfig /tmp/targetkubeconfig wait --for=condition=Ready node --all --timeout 900s

echo "Get cluster state"
kubectl --kubeconfig ${HOME}/.airship/kubeconfig get cluster
