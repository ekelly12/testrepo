#!/bin/bash

COMPILE_STR='g++ -g -Iisegfault -o "out/isegfault" "isegfault/isegfault.cpp"'
echo $COMPILE_STR
eval $COMPILE_STR
