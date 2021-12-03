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

ulimit -Hc unlimited
ulimit -c unlimited
sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
