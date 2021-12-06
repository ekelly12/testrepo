#!/bin/bash

if [ -z $1 ]
then
    echo "The OUT_DIR parameter is empty"
    exit 1
fi

programName=ithrowuncaughtex
expectedExitCode=126

OUT_DIR=$1
echo "OUT_DIR set to: $OUT_DIR"

# Set core dump file size limit.
ulimit -Sc unlimited

coreFileSize=$(ulimit -Sc)
echo "Core dump file size (soft)limit set to ($coreFileSize)"

# Run the program and captire the exit code.
returnCode=$("$OUT_DIR/$programName" || echo $?)

# Test to see if wthe expected exit code has been receieved.
if [ $returnCode ] && [ "$returnCode" < "$expectedExitCode" ]
then
	echo "$programName expectedly returned an exit code of $returnCode."
else
	echo "$programName returned an exit code other than $expectedExitCode."
	echo "exit code returned: '$returnCode'"
	exit 1
fi
