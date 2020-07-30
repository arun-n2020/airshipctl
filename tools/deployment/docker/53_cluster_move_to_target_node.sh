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

set -xe

export KUBECONFIG=${KUBECONFIG:-"/tmp/dtc.kubeconfig"}

echo "Switch context to management cluster"
airshipctl config set-context kind-capi-docker --manifest docker_manifest
airshipctl config use-context kind-capi-docker
airshipctl config get-context

echo "Move the cluster"
airshipctl cluster move --target-context dtc-admin@dtc --debug

echo "Check if nodes are ready for Target Cluster"
kubectl --kubeconfig $KUBECONFIG wait --for=condition=ready nodes --all --timeout=600s
kubectl --kubeconfig $KUBECONFIG get nodes -o wide
