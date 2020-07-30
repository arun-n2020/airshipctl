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

echo "Execute Local Overrides"
rm -rf ~/.cluster-api

export AIRSHIPCTL_WS=/home/zuul/src/opendev.org/airship/airshipctl


cd $AIRSHIPCTL_WS/manifests/function/capd && ./docker-overrides.py

echo "Created Local Overrides"

export KUBECONFIG=${KUBECONFIG:-"$HOME/.airship/kubeconfig"}

echo "Initialize Managment Cluster with CAPI and CAPD Components"

airshipctl cluster init --debug

echo "Waiting for all pods to come up"
kubectl --kubeconfig $KUBECONFIG wait --for=condition=ready pods --all --timeout=1000s -A
kubectl --kubeconfig $KUBECONFIG get pods -A
