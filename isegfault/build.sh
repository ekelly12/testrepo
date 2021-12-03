#!/bin/bash

COMPILE_STR="g++ -g -I$BUILD_ROOT/isegfault -o \"$BUILD_OUT_DIR/isegfault\" \"$BUILD_ROOT/isegfault/isegfault.cpp\""
echo $COMPILE_STR
eval $COMPILE_STR
