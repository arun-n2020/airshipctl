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

echo "Deploy Target Workload Cluster"
airshipctl phase apply docker

echo "Get kubeconfig from secret"
KUBECONFIG=""
N=0
MAX_RETRY=15
DELAY=10
until [ "$N" -ge ${MAX_RETRY} ]
do
  KUBECONFIG=$(kubectl --namespace=default get secret/dtc-kubeconfig -o jsonpath={.data.value}  || true)

  if [[ ! -z "$KUBECONFIG" ]]; then
      break
  fi

  N=$((N+1))
  echo "$N: Retry to get kubeconfig from secret."
  sleep ${DELAY}
done

if [[ -z "$KUBECONFIG" ]]; then
  echo "Error: Could not get kubeconfig from secret."
  exit 1
fi

echo "Generate kubeconfig"
echo ${KUBECONFIG} | base64 -d > /tmp/dtc.kubeconfig
echo "Generate kubeconfig: /tmp/dtc.kubeconfig"

echo "Wait for kubernetes cluster to be up"
VERSION=""
N=0
MAX_RETRY=30
DELAY=60
until [ "$N" -ge ${MAX_RETRY} ]
do
  VERSION=$(timeout 40 kubectl --kubeconfig /tmp/dtc.kubeconfig version | grep 'Server Version' || true)

  if [[ ! -z "$VERSION" ]]; then
      break
  fi

  N=$((N+1))
  echo "$N: Retry to get kubectl version."
  sleep ${DELAY}
done

if [[ -z "$VERSION" ]]; then
  echo "Error: Could not get kubectl version."
  exit 1
fi


echo "Check nodes status"

kubectl --kubeconfig /tmp/dtc.kubeconfig wait --for=condition=Ready nodes --all --timeout 900s
kubectl get nodes --kubeconfig /tmp/dtc.kubeconfig


echo "Waiting for all pods to come up"
kubectl --kubeconfig /tmp/dtc.kubeconfig  wait --for=condition=ready pods --all --timeout=2000s -A
kubectl --kubeconfig /tmp/dtc.kubeconfig get pods -A


echo "Get cluster state"
kubectl --kubeconfig ${HOME}/.airship/kubeconfig get cluster
