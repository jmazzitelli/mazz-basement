#!/bin/bash

set -e

echo "====Pulling the latest Kiali source code"
cd ${HOME}/source/kiali
git pull

# determine if we already have a pull secret
PULL_SECRET_FILE="${HOME}/pull-secret"
PULL_SECRET_ARG="-p ${PULL_SECRET_FILE}"

if [ ! -f "${PULL_SECRET_FILE}" ]; then
  echo "WARNING: There is no pull secret file at [${PULL_SECRET_FILE}]."
  echo "WARNING: You would need to enter it manually when the CRC startup script asks for it."
  PULL_SECRET_ARG=""

  # this script is run by cron - not reason to keep going since the script will need the pull secret
  exit 1
fi

echo "====Installing CRC"
./hack/crc-openshift.sh --crc-cpus 8 --crc-memory 64 --crc-virtual-disk-size 64 ${PULL_SECRET_ARG} start

echo "====Installing Istio"
./hack/istio/install-istio-via-istioctl.sh -c ${HOME}/bin/oc
