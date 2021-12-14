#!/bin/bash 

#gdb <path to gdb instructions file> -c <path to core file> -q -batch
gdb -x $1 -c $2 -q -batch
exit $?
