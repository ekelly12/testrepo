#!/bin/bash
# Copyright (C) Microsoft Corporation. All rights reserved.

# This script is for use on the linux VMs allocated for pipelined tests.
# It sourced to set the limit for any sub processes invoked via thecurrent shell.
CORE_TARGET_DEST=$1
if [ -z "$CORE_TARGET_DEST" ]; then CORE_TARGET_DEST=/tmp/core; fi

echo "ulimit -c unlimited"
currUser=$(whoami)
if [ ! -d "$CORE_TARGET_DEST" ]; then sudo mkdir -p "$CORE_TARGET_DEST"; fi
sudo chown $currUser "$CORE_TARGET_DEST"
# sysctl requires sudo
sudo sysctl -w kernel.core_pattern="$CORE_TARGET_DEST/%e-%p-%s-%u.core"
