#!/bin/bash

unset BUILD_ROOT
export BUILD_ROOT=$(pwd -P)
export BUILD_OUT_DIR="out"

# Create the output directory if it doesn't already exist.
if [ ! -d "$BUILD_OUT_DIR" ]
then
	mkdir "$BUILD_OUT_DIR"
fi

# Set ADO pipeline vars.
#echo "##vso[task.setvariable variable=BUILD_ROOT]$BUILD_ROOT"
#echo "##vso[task.setvariable variable=BUILD_OUT_DIR]$BUILD_OUT_DIR"

echo "Cleansing core dump files."
./utils/cleanse-core-dump-files.sh

# Set the rules for the core dump.
sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
