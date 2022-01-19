#!/bin/bash
# Copyright (C) Microsoft Corporation. All rights reserved.

# This script is for use on the linux VMs allocated for pipelined tests.
# It sourced to set the limit for any sub processes invoked via thecurrent shell.
CORE_TARGET_DEST=$1
if [ -z "$CORE_TARGET_DEST" ]; then CORE_TARGET_DEST=/tmp/core; fi
echo "ulimit -c unlimited" >> ~/.profile
currUser=$(whoami)
if [ ! -d "$CORE_TARGET_DEST" ]; then sudo mkdir -p "$CORE_TARGET_DEST"; fi
sudo chown "$currUser" "$CORE_TARGET_DEST"
# sysctl requires sudo
# Core pattern summary:
#   %f - Is similar to %e, however, it does not truncate the executable file name.
#   %p - Pid of the dumped process.
#   %s - The signal number of the signal that initiated the core dump. 
sudo sysctl -w kernel.core_pattern="$CORE_TARGET_DEST/%f-%p-%s.core"
