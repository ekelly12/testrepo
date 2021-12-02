#!/bin/bash

export BUILD_ROOT=/home/ekelly/ek
export BUILD_LIB="$BUILD_ROOT/signals"
export BUILD_SOURCE="$BUILD_ROOT/signals"

echo "##vso[task.setvariable variable=BUILD_ROOT;isOutput=true]$BUILD_ROOT"
echo "##vso[task.setvariable variable=BUILD_LIB;isOutput=true]$BUILD_LIB"
echo "##vso[task.setvariable variable=BUILD_SOURCE;isOutput=true]$BUILD_SOURCE"

ulimit -c unlimited \
&& sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
