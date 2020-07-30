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

export KUBECONFIG=${KUBECONFIG:-"/tmp/dtc.kubeconfig"}

#
# Deploy Helm operator
#

echo "Deploy Helm Operator on Target Workload Cluster"
airshipctl phase apply initinfra

echo "Check helm-controller pod status"

echo "Waiting for pod to come up..."
kubectl --kubeconfig /tmp/dtc.kubeconfig  wait --for=condition=ready pods --all --timeout=2000s -n flux
kubectl --kubeconfig /tmp/dtc.kubeconfig get pods -n flux

#
# Deploy Multus CNI plugin
#

echo "Deploy Multus CNI plugin on Target Workload Cluster"
airshipctl phase apply multus

echo "Check multus pods status"

echo "Waiting for pods to come up..."
kubectl --kubeconfig /tmp/dtc.kubeconfig  wait --for=condition=ready pods --all --timeout=2000s -n kube-system
kubectl --kubeconfig /tmp/dtc.kubeconfig get pods -n kube-system

#
# Deploy sample CNF (VPP ipforwarder)
#

echo "Deploy sample CNF on Target Workload Cluster"
airshipctl phase apply ipforwarder

echo "Check ipforwarder pods status"

echo "Waiting for pods to come up..."
kubectl --kubeconfig /tmp/dtc.kubeconfig  wait --for=condition=ready pods --all --timeout=2000s -n ipforwarder
kubectl --kubeconfig /tmp/dtc.kubeconfig get pods -n ipforwarder
