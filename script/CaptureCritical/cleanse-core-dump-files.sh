#!/bin/bash

if [ -z $1 ]
then
	echo "The core dump file directory was not passed in"
	exit 1
fi

echo "Core dump file directory: $1"

rm -f /tmp/core/*
