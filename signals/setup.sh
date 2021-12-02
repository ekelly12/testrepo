#!/bin/bash

export BUILD_ROOT=/home/ekelly/ek

cd $BUILD_ROOT

export BUILD_LIB="./signals"
export BUILD_SOURCE="./signals"

echo "##vso[task.setvariable variable=BUILD_ROOT;isOutput=true]$BUILD_ROOT"
echo "##vso[task.setvariable variable=BUILD_LIB;isOutput=true]$BUILD_LIB"
echo "##vso[task.setvariable variable=BUILD_SOURCE;isOutput=true]$BUILD_SOURCE"

ulimit -c unlimited \
&& sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
