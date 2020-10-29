#!/bin/bash

# DETERMINE IF WE ARE TO INSTALL OR DESTROY THE CLUSTER

case $1 in
  install) ADDITIONAL_ARGS="--autostart-vms";;
  destroy) ADDITIONAL_ARGS="--destroy";;
  *) echo "Must pass in either 'install' or 'destroy'"; exit 1;;
esac

# GET ENVIRONMENT

source env.sh
cd ${SCRIPT_DIR}

INSTALL_CMD="${INSTALL_CMD} ${ADDITIONAL_ARGS}"

# CONFIRM

cat <<EOM

The following command will be executed.

  ${INSTALL_CMD}

EOM

select yn in "Are you sure?" "Abort!"; do
  case $yn in
    "Are you sure?" ) break;;
    "Abort!" )        echo "Aborting..."; exit 1;;
  esac
done

# EXECUTE!

sudo ${INSTALL_CMD}
