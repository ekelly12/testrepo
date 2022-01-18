#!/bin/bash 
# Copyright (C) Microsoft Corporation. All rights reserved.

# Checking for required arguments.
missingReqArg=0
if [ -z $1 ]; then echo "Missing arg: core directory" && missingReqArg=1; fi
if [ -z $2 ]; then echo "Missing arg: executable directory path" && missingReqArg=1; fi;
if [ -z $3 ]; then echo "Missing arg: the path to the gdb instructions file to use" && missingReqArg=1; fi;
if [ $missingReqArg -eq 1 ]; then exit; fi

coreFileSoureDirPath="$1"
execDirPath="$2"
gdb_instructions_file="$3"

create_mini_dump_file()
{
	coreFilePath="$1"
	exeFilePath="$execDirPath/$2"
	outputFile="$coreFilePath.minidump"
    echo "gdb -se \"$exeFilePath\" -x \"$gdb_instructions_file\" -c \"$coreFilePath\" -q -batch > \"$outputFile\""
    gdb -se "$exeFilePath" -x "$gdb_instructions_file" -c "$coreFilePath" -q -batch > "$outputFile"
    exit $?	
}

handle_minidump()
{
    coreFilePath="$1"
	echo "Handling the core dump file at: $coreFilePath"
    IFS='-'
    read -rasplitIFS<<< "$1"
    exeName="${splitIFS[0]}"
    IFS=''
    create_mini_dump_file "$coreFileSoureDirPath/$coreFilePath" "$exeName"
}

# Find all core files in the core fiule source directory.
for i in `find "$coreFileSoureDirPath" -maxdepth 1 -type f -name "*.core" -printf "%f\n"`; do
	handle_minidump "$i"
done
