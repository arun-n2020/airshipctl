#!/bin/bash

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

#Default wait timeout is 3600 seconds
export TIMEOUT=${TIMEOUT:-3600}
export KUBECONFIG=${KUBECONFIG:-"$HOME/.kube/config"}


REMOTE_WORK_DIR=/tmp

echo "Create Kind Cluster"
cat <<EOF >  ${REMOTE_WORK_DIR}/kind-cluster-with-extramounts.yaml
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: /var/run/docker.sock
        containerPath: /var/run/docker.sock
EOF
kind delete cluster --name capi-docker
kind delete cluster --name dtc
kind delete cluster --name docker-target-cluster
kind create cluster --config ${REMOTE_WORK_DIR}/kind-cluster-with-extramounts.yaml --name capi-docker


#Wait till Capi Docker Control Plane Node is ready
end=$(($(date +%s) + $TIMEOUT))
echo "Waiting $TIMEOUT seconds for Capi Docker Control Plane node to be ready."
while true; do
    if (kubectl --request-timeout 20s --kubeconfig $KUBECONFIG get nodes capi-docker-control-plane -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' | grep -q True) ; then
        echo -e "\nCapi Docker Control Plane Node is ready."
        kubectl --request-timeout 20s --kubeconfig $KUBECONFIG get nodes
        break
    else
        now=$(date +%s)
        if [ $now -gt $end ]; then
            echo -e "\nCapi Docker Control Plane Node was not ready before TIMEOUT."
            exit 1
        fi
        echo -n .
        sleep 15
    fi
done
