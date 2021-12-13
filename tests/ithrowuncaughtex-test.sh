#!/bin/bash

if [ -z $1 ]
then
    echo "The OUT_DIR parameter is empty"
    exit 1
fi

programName=ithrowuncaughtex
expectedExitCode=">0"

OUT_DIR=$1
echo "OUT_DIR set to: $OUT_DIR"

# Set core dump file size limit.
#ulimit -Sc unlimited

coreFileSize=$(ulimit -Sc)
echo "Core dump file size (soft)limit set to ($coreFileSize)"

# Run the program and captire the exit code.
progPath="$OUT_DIR/$programName"
echo "Running $progPath"
returnCode=$($progPath || echo $?)

# Test to see if wthe expected exit code has been receieved.
if [ $returnCode ]
then
	echo "$programName expectedly returned an exit code of $returnCode(>0)."
else
	echo "$programName returned an exit code other than $expectedExitCode."
	echo "exit code returned: '$returnCode'"
	exit 1
fi
