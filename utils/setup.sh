#!/bin/bash

unset BUILD_ROOT
export BUILD_ROOT=$(pwd -P)
export BUILD_OUT_DIR="out"

# Create the output directory if it doesn't already exist.
if [ ! -d "$BUILD_OUT_DIR" ]
then
	mkdir "$BUILD_OUT_DIR"
fi

# Create directory for core dumps to be written to.
coreDumpDir=/tmp/core
if [ ! -d $coreDumpDir ]
then
    mkdir $coreDumpDir
	retCode=$?
	if [ ! $retCode == 0 ]
	then
		echo "Failed to create the core dump directory"
		exit $retCode
	fi
else
	echo "Cleansing core dump files."
	./utils/cleanse-core-dump-files.sh
fi

# Set the rules for the core dump.
sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core

# Set ADO pipeline vars.
#echo "##vso[task.setvariable variable=BUILD_ROOT]$BUILD_ROOT"
#echo "##vso[task.setvariable variable=BUILD_OUT_DIR]$BUILD_OUT_DIR"
