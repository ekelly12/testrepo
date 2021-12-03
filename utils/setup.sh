#!/bin/bash

export BUILD_ROOT=$(pwd -P)
export BUILD_OUT_DIR="$BUILD_ROOT/out"

# Create the output directory if it doesn't already exist.
if [ ! -d "$BUILD_OUT_DIR" ]
then
	mkdir "$BUILD_OUT_DIR"
fi

echo "Cleansing core dump files."
#./$BUILD_LIB/cleanse-core-dump-files.sh

ulimit -c unlimited \
&& sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
