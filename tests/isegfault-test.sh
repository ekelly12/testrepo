#!/bin/bash

if [ -z $1 ]
then
    echo "The OUT_DIR parameter is empty"
    exit 1
fi

programName=isegfault
expectedExitCode=139

OUT_DIR=$1
echo "OUT_DIR set to: $OUT_DIR"

# Set core dump file size limit.
#ulimit -Sc unlimited

coreFileSize=$(ulimit -Sc)
echo "Core dump file size (soft)limit set to ($coreFileSize)"

# Run isegfault and captire the exit code.
returnCode=$("$OUT_DIR/isegfault" || echo $?)

# Test to see if wthe expected exit code has been receieved.
if [ $returnCode ] && [ "$returnCode" -eq "$expectedExitCode" ]
then
	echo "isegfault expectedly returned an exit code of $returnCode."
else
	echo "isegfault returned an exit code other than $expectedExitCode."
	echo "exit code returned: '$returnCode'"
	exit 1
fi
