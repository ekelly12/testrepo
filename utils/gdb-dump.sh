#!/bin/bash 

gdb $1 -x $2 -c $3 -q -batch
#gdb <path to executable> -x <path to gdb instructions file> -c <path to core file> -q -batch
