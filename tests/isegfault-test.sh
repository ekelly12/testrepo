#!/bin/bash

# Set core dump file size limit.
ulimit -Sc 99999999

coreFileSize=$(ulimit -Sc)
echo "Core dump file size (soft)limit set to $coreFileSize)"

# Run isegfault and captire the exit code.
returnCode=$($BUILD_ROOT/out/isegfault || echo $?)

# Test to see if wthe expected exit code has been receieved.
if [ $returnCode == 139 ]
then
	echo "isegfault expectedly returned an exit code of 139."
else
	echo "isegfault returned an exist code other than 139."
	echo "exit code returned: '$returnCode'"
	exit 1
fi
