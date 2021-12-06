#!/bin/bash

# Check for required parameters.
if [ -z $1 ]
then
	echo "The BUILD_ROOT parameter is empty"
	exit 1
fi
BUILD_ROOT=$1
echo "BUILD_ROOT set to: $BUILD_ROOT"

if [ -z $2 ]
then
    echo "The OUT_DIR parameter is empty"
    exit 1
fi
OUT_DIR=$2
echo "OUT_DIR set to: $OUT_DIR"

# Create the output directory if it doesn't already exist.
if [ ! -d "$OUT_DIR" ] 
then 
	sudo mkdir "$OUT_DIR" 
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
	./utils/cleanse-core-dump-files.sh $coreDumpDir
fi

# GDB *should definietly* be installed
gdbInstalled=$(which gdb)
if [ -v $gdbInstalled ]
then
	echo "gdb is not installed."
	echo "Attempting to install it, now."
	sudo apt install gdb
else
	echo "dbg is already installed."
fi

# Did the install attempt work?
gdbInstalled=$(which gdb)
if [ -v $gdbInstalled ]
then
	echo "Failed to install gdb."
fi

# Set the rules for the core dump.
#sudo sysctl -w kernel.core_pattern="|/tmp/core-handler.py $coreDumpDir %e-%p-%s-%u.core"
sudo sysctl -w kernel.core_pattern="/tmp/core/%e-%p-%s-%u.core"
