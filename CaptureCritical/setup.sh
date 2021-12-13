#!/bin/bash

# Check for required parameters.
# First parameter, BUILD_ROOT.
if [ -z $1 ]
then
	echo "The BUILD_ROOT parameter is empty"
	exit 1
fi
BUILD_ROOT=$1
echo "BUILD_ROOT set to: $BUILD_ROOT"

# Second paramater is the target desination of the core dump files
# written by the OS.
if [ -z $2 ]
then
	echo "The CORE_DEST_DIR parameter is empty."
	exit 1
fi
CORE_DEST_DIR=$2
echo "CORE_DEST_DIR set to: $CORE_DEST_DIR"

# Create directory for core dumps to be written to.
if [ ! -d $CORE_DEST_DIR ]
then
    mkdir $CORE_DEST_DIR
	retCode=$?
	if [ ! $retCode == 0 ]
	then
		echo "Failed to create the core dump directory"
		exit $retCode
	fi
else
	echo "Cleansing core dump files."
	$BUILD_ROOT/cleanse-core-dump-files.sh $CORE_DEST_DIR
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
sudo sysctl -w kernel.core_pattern="$CORE_DEST_DIR/%e-%p-%s-%u.core"
