#!/bin/bash

export BUILD_ROOT=/home/ekelly/ek
export BUILD_LIB="$BUILD_ROOT/signals"
export BUILD_SOURCE="$BUILD_ROOT/signals"

echo "##vso[task.setvariable variable=BUILD_ROOT]$BUILD_ROOT"
echo "##vso[task.setvariable variable=BUILD_LIB]$BUILD_LIB"
echo "##vso[task.setvariable variable=BUILD_SOURCE]$BUILD_SOURCE"

ulimit -c unlimited \
&& sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
