#!/bin/bash

coreSourcePath="/tmp/core"

echo "Has the core target been created?"
if [ ! -d "$coreSourcePath" ]; then echo "$coreSourcePath has not been created"; else echo "$coreSourcePath exists"; fi

echo "KILL TEST(For core file generation)"
ulimit -Sc unlimited

sleep 200&
kill -s SIGABRT $!

if [ -d "$coreSourcePath" ]
then
    coreFiles=$(ls ''${coreSourcePath:?}/*'' 2>/dev/null)
    if [ -z "$coreFiles" ]; then echo "No core files were generated."; else echo "found the generated core file: $coreFiles"; fi
    # Cleanse the core file directory, now that the test is finish.
    rm -fr ''${coreSourcePath:?}/*'' 2>/dev/null
fi

