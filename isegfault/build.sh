#!/bin/bash

COMPILE_STR="g++ -g -I./isegfault -o \"./isegfault/isegfault\" \"./isegfault/isegfault.cpp\""
echo $COMPILE_STR
eval $COMPILE_STR
