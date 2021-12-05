#!/bin/bash

if [ -z $1 ] 
then 
	echo "The BUILD_ROOT parameter is empty"
	exit 1
fi
BUILD_ROOT=$1
echo "BUILD_ROOT set to: $BUILD_ROOT"

if [ -z $2 ]
then
	echo "The OUT_DIR parameter is empty"
	exit 1
fi
OUT_DIR=$2
echo "OUT_DIR set to: $OUT_DIR"

COMPILE_STR="g++ -g -I$BUILD_ROOT/isegfault -o \"$OUT_DIR/isegfault\" \"$BUILD_ROOT/isegfault/isegfault.cpp\""
echo $COMPILE_STR
eval $COMPILE_STR
