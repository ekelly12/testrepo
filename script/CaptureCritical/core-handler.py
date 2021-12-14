#!/usr/bin/python3
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
        # Run the command that will retrieve the gdb dump then store it.
        core_file_handler(full_path)


def run_stdin():
    out_add('Received core dump with the given process name: ' + process_filename)
    write_dump(core_target_dir, process_filename)

# Calls gdb to generate backtrace and register dumps, etc.
# Loops through all discovered executables for unique gdb output
# Then groups the executables by it.


def core_file_handler(core_file_path):
    out_add("Dumping the core file: " + core_file_path)
    mini_dump = gdb_gen_construct(core_file_path, gdb_instructions_file_path)
    out_add("Backtrace and registers")
    out_add(mini_dump)


def gdb_gen_construct(core_file_path, path_to_instructions):
    cmd_params = (os.path.join(util_root, gdb_gen_file_path), path_to_instructions, core_file_path)
    command = ' '.join(cmd_params)
    out_add("Running command: " + command)
    p = Popen(command, shell=True, stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True)
    output = p.stdout.read()
    res = p.communicate()
    if (p.returncode != 0):
        out_add("The command failed with the error code: " + str(p.returncode))
        for line in res[0].decode(encoding='utf-8').split('\n'):
            out_add(line)
        die()
    return output.decode('utf-8')


def die():
    exit(1)


def main():
    global util_root, core_target_dir, process_filename, test_flag, exit_code, gdb_gen_file_path, gdb_instructions_file_path
    # Command line argument handling.
    if (not len(sys.argv) > 3):
        out_add("Not enough arguments")
        out_print()
        exit(1)
    run_mode = sys.argv[1]
    # This script *should* be able to run in these modes:
    # 1) "reader" - Will scan core_target_dir for handled core dumps.
    # 2) "receiver" - Will receieve core dumps, via STDIN, from the kernel.
    # 3) "test" - Will cause this script to set test_flag to True. Then run as "reader".
    if (run_mode == 'test'):
        test_flag = True
        run_mode = "reader"
    if (run_mode == 'reader'):
        core_target_dir = sys.argv[2]
        util_root = sys.argv[3]
        gdb_gen_file_path = os.path.join(util_root, 'gdb-dump.sh')
        gdb_instructions_file_path = os.path.join(util_root, 'gdb-dump-instructions.txt')
        run_read(core_target_dir)
    elif (run_mode == 'receiver'):
        # Killing this feature for now.
        # Eventually, it or something like it may be used to display runtime crashes.
        out_add("The feture is not yet implemented!")
        return
        core_target_dir = sys.argv[2]
        process_filename = sys.argv[3]
        run_stdin()
    else:
        out_add("Didn't receive a correct run mode. Exiting.")
        exit_code = 1
    out_print()


main()
exit(exit_code)
