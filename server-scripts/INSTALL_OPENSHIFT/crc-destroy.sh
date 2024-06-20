#!/bin/bash

set -e

echo "====Pulling the latest Kiali source code"
cd ${HOME}/source/kiali
git pull

echo "====Destroying CRC"
if ! ./hack/crc-openshift.sh delete; then
  echo "Attempt to delete failed - CRC was likely not running."
  exit 0
fi
