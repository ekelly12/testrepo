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
print_to_term   = False
print_to_stdout = True
print_immediate = True

# Path to the shell script that generates gdb output.
gdb_gen_file_path          = "utils/gdb-dump.sh"
# Path to the dbg instructions file.
gdb_instructions_file_path = "utils/gdb-dump-instructions.txt"
# Dict to house a list of executables containing debug info to query for symbols.
exec_list_dict  = {}
# Message output array.
term_output     = []
# Core file to exec map.
core_map        = {}
# A map of md5 strings to the original gdb inspection content.
gdb_output_map  = {}

# Formatting helpers.
line_separator = "\n===================\n"
tab_indent     = "\t ===> "

def out_add(message):
    if (bool(print_immediate) == True):
        print(message)
    else:
        term_output.append(message)

def out_print():
    if (bool(print_to_term) == True):
        for msg in term_output:
            print(msg)
    if (bool(print_to_stdout) == True):
        for msg in term_output:
            print(msg)

def write_dump(target_dir, filename):
    if not select.select([sys.stdin,],[],[],0.0)[0]:
        out_add("stdin has no data ready")
        out_print()       
        exit(1)
    target_file = target_dir + '/' + filename
    with open(target_file, "wb") as core_dump:
        core_contents = bytearray(sys.stdin.read())
        core_dump.write(core_contents)

def read_dir(path):
    out_add("Reading the contents of: " + path)
    files = os.listdir(path)
    if (not len(files)):
        return False;
    files_out = [];
    for file in files:
        if (file.startswith('.')):
            continue
        files_out.append(file)
    return files_out

def run_read(core_dir):
    files = read_dir(core_dir)
    if (bool(files) == False):
        out_add("Found no files")
        return
    # Loop through found core files.
    for file in files:
        if (bool(file.endswith('.gz')) == True):
            continue
        full_path = core_dir + '/' + file
        # Determine if these files are handled by this script.
        name_segments = file.split('-');
        # Create compressed versions to store as artifacts.
        command = "gzip -c " + full_path + " > " + full_path + ".gz"
        out_add("Running command: " + command);
        os.system(command)
        # Run the command that will retrieve the gdb dump then store it.
        core_file_handler(full_path)

def run_stdin():
    out_add('Received core dump with the given process name: ' + process_filename)
    write_dump(core_target_dir, process_filename)

def build_executable_list(exec_path_file):
    if (not os.path.isfile(exec_path_file)):
        out_add("The executable directory file at: " + exec_path_file + " does not exist.")
        die()
    out_add("Reading the file: " + exec_path_file + " for directories to scan for executables.")
    dir_file = open(exec_path_file, "r")
    read_line = dir_file.readline()
    while read_line:
        scan_path_for_execs(read_line.rstrip('\n'))
        read_line = dir_file.readline()

# This should change later.
def scan_path_for_execs(path):
    out_add("Scanning this path for executables: " + path)
    files = read_dir(path)
    if (bool(files) == False):
        return False
    for file in files:
        full_file_path = path + '/' + file
        is_executable = os.access(full_file_path, os.X_OK)
        if (bool(is_executable) == True):
            out_add("Found an execuatble at: " + full_file_path)
            exec_list_dict[file] = full_file_path
    out_add("Done.")

# Calls gdb to generate backtrace and register dumps, etc.
# Loops through all discovered executables for unique gdb output
# Then groups the executables by it.
def core_file_handler(core_file_path):
    out_add("Dumping the core file: " + core_file_path)
    if (len(exec_list_dict) < 1):
        out_add("The executable list is empty. Will simply generate the gdb bt without debug symbols.")
        gdb_gen_construct(core_file_path,'',gdb_instructions_file_path)
        return
    for exec_path in exec_list_dict.values():
        gdb_gen_construct(core_file_path,exec_path,gdb_instructions_file_path)
    # Print out the results.
    # Results are grouped by the md5 hex encoded values of the gdb inspections.
    for core_key in core_map:
        out_add(line_separator + "Results for the core dump at: " + core_key)
        for inspection_key in core_map[core_key]:
            out_add("Unique result: " + inspection_key)
            out_add("Returned by these executable files:")
            for exec_key in core_map[core_key][inspection_key]:
                out_add(tab_indent + exec_key)
            out_add("Backtrace and registers")
            out_add(gdb_output_map[inspection_key])
            out_add(line_separator)

def gdb_gen_construct(core_file_path,path_to_exec,path_to_instructions):
    cmd_params = (gdb_gen_file_path,path_to_exec,path_to_instructions,core_file_path)
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
    output_utf8 = output.decode('utf-8')
    # Create the core map key, if it doesn't already exist.
    if (not core_file_path in core_map):
        core_map[core_file_path] = {}
    hash_map = core_map.get(core_file_path)
    # Create an MD5 representation of the gdb out, for matching.
    md5 = hashlib.md5(output).hexdigest()
    # Save the decoded output to the output dict.
    gdb_output_map[md5] = output_utf8
    if (not md5 in hash_map):
        hash_map[md5] = []
    exec_list = hash_map.get(md5)
    exec_list.append(path_to_exec)

def die():
    exit(1);

def main():
    # Command line argument handling.
    if (not len(sys.argv) > 3):
        out_add("Not enough arguments")
        out_print()
        exit(1)
    run_mode            = sys.argv[1]
    exit_code           = 0;
    # This script *should* be able to run in these modes:
    # 1) "reader" - Will scan core_target_dir for handled core dumps.
    # 2) "receiver" -Will receieve core dumps, via STDIN, from the kernel.
    if (run_mode == 'reader'):
        core_target_dir     = sys.argv[2]
        exec_path_file      = sys.argv[3]
        build_executable_list(exec_path_file)
        run_read(core_target_dir)
    elif (run_mode == 'receiver'):
        core_target_dir     = sys.argv[2]
        process_filename    = sys.argv[3]
        exec_path_file      = sys.argv[4]
        run_stdin()
    else:
        out_add("Didn't receive a correct run mode. Exiting.")
        exit_code = 1
    out_print()
    exit(exit_code)

main()
