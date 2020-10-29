#!/bin/bash

source env.sh

echo -n "The kubeadmin password is: "
sudo cat ${OCP4_SETUP_DIR}/install_dir/auth/kubeadmin-password
echo
