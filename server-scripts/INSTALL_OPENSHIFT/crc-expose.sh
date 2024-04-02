#!/bin/bash

set -e

echo "====Pulling the latest Kiali source code"
cd ${HOME}/source/kiali
git pull

# use "expose" to set firewall rules
./hack/crc-openshift.sh expose
