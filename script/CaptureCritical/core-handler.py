#!/usr/bin/python3
import argparse
import sys
import select
import os
import os.path
import re
import subprocess
from subprocess import Popen, PIPE, STDOUT, DEVNULL
import hashlib

# Config
print_to_term = False
print_to_stdout = True
print_immediate = True
test_flag = False

# Path to where all resources for this utility resides.
# Defaulted to the cwd.
util_root = '.'
# Path to the shell script that generates gdb output.
gdb_gen_file_path = None
# Path to the dbg instructions file.
gdb_instructions_file_path = None

# Message output array.
term_output = []

# Formatting helpers.
line_separator = "\n===================\n"
tab_indent = "\t ===> "

# Script exit code.
exit_code = 0

parser = argparse.ArgumentParser(
    description='Handler for core files.')

parser.add_argument(
    '--runmode',
    '-r',
    type=str,
    default='reader',
    help="The 'run mode' for this script (reader|test)")

parser.add_argument(
    '--coretargetdir',
    '-t',
    type=str,
    required=True,
    help="The full path to the target core dump source directory.")

parser.add_argument(
    '--utilroot',
    '-u',
    type=str,
    required=True,
    help="The full path to directory containing the utils used by this script.")

# parsing arguments.
args = parser.parse_args()


def out_add(message):
    if (bool(print_immediate)):
        print(message)
    else:
        term_output.append(message)


def out_print():
    if (bool(print_to_term)):
        for msg in term_output:
            print(msg)
    if (bool(print_to_stdout)):
        for msg in term_output:
            print(msg)


def write_dump(target_dir, filename):
    if not select.select([sys.stdin, ], [], [], 0.0)[0]:
        out_add("stdin has no data ready")
        out_print()
        exit(1)
    target_file = os.path.join(target_dir, filename)
    with open(target_file, "wb") as core_dump:
        core_contents = bytearray(sys.stdin.read())
        core_dump.write(core_contents)


def read_dir(path):
    out_add("Reading the contents of: " + path)
    files = os.listdir(path)
    if (not len(files)):
        return False
    files_out = []
    for file in files:
        if (file.startswith('.')):
            continue
        files_out.append(file)
    return files_out


def run_read(core_dir):
    global exit_code, test_flag
    files = read_dir(core_dir)
    if (bool(files) == False):
        out_add("Found no files")
        return
    # Loop through found core files.
    for file in files:
        if (bool(file.endswith('.gz'))):
            continue
        # Reset the exit code here.
        # Always return an exit code greater than 1 if any core files are handled,
        # unless the test_flag bool is set to True
        if (bool(test_flag) == False):
            exit_code = 1
        full_path = os.path.join(core_dir, file)
        # Determine if these files are handled by this script.
        name_segments = file.split('-')
        # Create compressed versions to store as artifacts.
        command = "gzip -c " + full_path + " > " + full_path + ".gz"
        out_add("Running command: " + command)
        os.system(command)


def run_stdin():
    out_add(
        'Received core dump with the given process name: ' +
        process_filename)
    write_dump(core_target_dir, process_filename)


def die():
    exit(1)


def main():
    global util_root, core_target_dir, process_filename, test_flag, exit_code, gdb_gen_file_path, gdb_instructions_file_path
    run_mode = args.runmode
    # This script *should* be able to run in these modes:
    # 1) "reader" - Will scan core_target_dir for handled core dumps.
    # 2) "receiver" - Will receieve core dumps, via STDIN, from the kernel.
    # 3) "test" - Will cause this script to set test_flag to True. Then run as
    # "reader".
    if (run_mode == 'test'):
        test_flag = True
        run_mode = "reader"
    if (run_mode == 'reader'):
        core_target_dir = args.coretargetdir
        util_root = args.utilroot
        gdb_gen_file_path = os.path.join(util_root, 'gdb-dump.sh')
        gdb_instructions_file_path = os.path.join(
            util_root, 'gdb-dump-instructions.txt')
        run_read(core_target_dir)
    else:
        out_add("Didn't receive a correct run mode. Exiting.")
        exit_code = 1
    out_print()


main()
exit(exit_code)
