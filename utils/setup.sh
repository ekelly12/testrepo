#!/bin/bash

export BUILD_ROOT=$(pwd -P)
export BUILD_OUT_DIR="$BUILD_ROOT/out"

# Create the output directory if it doesn't already exist.
if [ ! -d "$BUILD_OUT_DIR" ]
then
	mkdir "$BUILD_OUT_DIR"
fi

# Set ADO pipeline vars.
echo "##vso[task.setvariable variable=BUILD_ROOT]$BUILD_ROOT"
echo "##vso[task.setvariable variable=BUILD_OUT_DIR]$BUILD_OUT_DIR"

echo "Cleansing core dump files."
#./$BUILD_LIB/cleanse-core-dump-files.sh

# Set the core file size limits.
ulimit -Hc unlimited
ulimit -Sc 8888888

# Set the rules for the core dump.
sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
