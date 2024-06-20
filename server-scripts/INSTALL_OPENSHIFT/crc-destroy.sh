#!/bin/bash

echo "====Pulling the latest Kiali source code"
cd ${HOME}/source/kiali
git pull

echo "====Destroying CRC"
./hack/crc-openshift.sh delete
