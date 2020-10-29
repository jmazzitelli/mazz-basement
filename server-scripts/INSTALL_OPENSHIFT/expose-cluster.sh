#!/bin/bash

source env.sh

sudo ${OCP4_SETUP_DIR}/expose_cluster.sh --method firewalld
