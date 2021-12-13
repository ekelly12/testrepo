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
if [ ! -d $OUT_DIR ]
then
    mkdir $OUT_DIR
fi

COMPILE_STR="clang++ -g -I$BUILD_ROOT/ithrowuncaughtex -o \"$OUT_DIR/ithrowuncaughtex\" \"$BUILD_ROOT/ithrowuncaughtex/main.cpp\""
echo $COMPILE_STR
eval $COMPILE_STR
