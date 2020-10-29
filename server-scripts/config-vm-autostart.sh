#!/bin/bash

err() {
    echo; echo;
    echo -e "\e[97m\e[101m[ERROR]\e[0m ${1}"; shift; echo;
    while [[ $# -gt 0 ]]; do echo "    $1"; shift; done
    echo; exit 1;
}

# Checking if we are root
test "$(whoami)" = "root" || err "Not running as root"

case $1 in
  yes)
    # get all VMs that are not currently configured with autostart
    vms_to_configure="$(virsh list --all --name --no-autostart)"
    disable_opt=""
    echo "Will configure VMs to autostart at boot time"
    ;;
  no)
    # get all VMs that are currently configured with autostart
    # and set the disable option so we pass it in when virsh autostart is executed
    vms_to_configure="$(virsh list --all --name --autostart)"
    disable_opt="--disable"
    echo "Will configure VMs to NOT autostart at boot time"
    ;;
  *)
    err "Pass in either 'yes' (if you want the VMs autostarted at boot time) or 'no'"
esac

for vm in ${vms_to_configure}
do
  echo "Configuring VM: ${vm}"
  virsh autostart ${disable_opt} ${vm} || err "Failed to configure VM: ${vm}"
done
