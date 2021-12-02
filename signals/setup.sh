#!/bin/bash

export BUILD_ROOT=/home/ekelly/ek
export BUILD_LIB="$BUILD_ROOT/signals"
export BUILD_SOURCE="$BUILD_ROOT/signals"

ulimit -c unlimited \
&& sudo sysctl -w kernel.core_pattern=/tmp/core/%e-%p-%s-%u.core
