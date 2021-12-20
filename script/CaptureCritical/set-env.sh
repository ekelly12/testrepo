#!/usr/bin/bash
# Copyright (C) Microsoft Corporation. All rights reserved.

# This script is for use on the linux VMs allocated for pipelined tests.
# It sourced to set the limit for any sub processes invoked via thecurrent shell.
if [ -z "$1" ]; then echo "Empty parameter 1 - core target path" && exit; fi

export CORE_TARGET_DEST=$1
ulimit -Sc unlimited
if [ ! -d "$CORE_TARGET_DEST" ]; then mkdir -p "$CORE_TARGET_DEST"; fi
touch "$CORE_TARGET_DEST"/test.core # testing
# sysctl requires sudo
sudo sysctl -w kernel.core_pattern="$CORE_TARGET_DEST/%e-%p-%s-%u.core"
