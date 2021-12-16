#!/bin/bash
# Copyright (C) Microsoft Corporation. All rights reserved.

# NOTE: This script must be called as root or via sudo.

if ((EUID != 0)); then
  echo "Please run as root - current Effective UID = ${EUID}"
  id
  exit 1
fi

# Check for required parameters.
# First parameter, BUILD_ROOT.
if [ -z "$1" ]
then
    echo "The BUILD_ROOT parameter is empty"
    exit 1
fi
export BUILD_ROOT="$1"
echo "##vso[task.setvariable variable=BuildRoot]$BUILD_ROOT"
echo "BUILD_ROOT set to: $BUILD_ROOT"

# Second paramater is the target desination of the core dump files
# written by the OS.
if [ -z "$2" ]
then
    echo "The CORE_DEST_DIR parameter is empty."
    exit 1
fi
CORE_DEST_DIR=$2
echo "CORE_DEST_DIR set to: $CORE_DEST_DIR"

# Create directory for core dumps to be written to.
if [ ! -d "$CORE_DEST_DIR" ]
then
    mkdir -p "$CORE_DEST_DIR"
    retCode=$?
    if [ ! $retCode == 0 ]
    then
        echo "Failed to create the core dump directory"
        exit $retCode
    fi
else
    echo "Cleansing core dump files."
    "$BUILD_ROOT"/cleanse-core-dump-files.sh "$CORE_DEST_DIR"
fi

# Set the rules for the core dump.
sysctl -w kernel.core_pattern="$CORE_DEST_DIR/%e-%p-%s-%u.core"
