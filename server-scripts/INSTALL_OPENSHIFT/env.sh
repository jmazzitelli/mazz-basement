#!/bin/bash

MASTERS="3"
WORKERS="0"
OPENSHIFT_VERSION="4.7.20"

SCRIPT_DIR="${HOME}/source/ocp4_setup_upi_kvm"
SCRIPT_EXE="${SCRIPT_DIR}/ocp4_setup_upi_kvm.sh"

INSTALL_CMD="${SCRIPT_EXE} -y -m ${MASTERS} -w ${WORKERS} -O ${OPENSHIFT_VERSION}"

OCP4_SETUP_DIR="/root/ocp4_setup_ocp4"
