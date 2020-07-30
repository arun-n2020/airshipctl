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

echo "Installing Kind"

set -xe

: ${KIND_VERSION:="v0.7.0"}

# Kind URL
URL="https://github.com/kubernetes-sigs"
sudo -E curl -sSLo /usr/local/bin/kind \
  "${URL}"/kind/releases/download/"${KIND_VERSION}"/kind-$(uname)-amd64

sudo -E chmod +x /usr/local/bin/kind
