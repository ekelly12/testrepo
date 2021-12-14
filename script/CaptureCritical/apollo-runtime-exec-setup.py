#!/usr/bin/python3

import os
import glob
import zipfile
import shutil

#tests_root_dir = os.path.normpath('/home/ekelly/Apollo/tests')
#tests_zip_dir = os.path.join(tests_root_dir,'ApolloNPU_RELWITHDEBINFO-0.0.1-Linux-tests')

working_dir = '/home/ekelly/Apollo/tests/capture-critical'

exec_dir_path_file = os.path.join(working_dir,'linux_tests_exec_paths.txt')

zip_file_path = os.path.normpath('/home/ekelly/Apollo/cmake-build-linux/ApolloNPU_RELWITHDEBINFO-0.0.1-Linux-tests.zip')
print("Extracting executables from: " + zip_file_path)

exec_target_dir = os.path.join(working_dir)
print("Into: " + exec_target_dir)

# Create or re-create the target directory for executables.
if os.path.exists(exec_target_dir):
    shutil.rmtree(exec_target_dir)
os.makedirs(exec_target_dir, exist_ok=True)
with zipfile.ZipFile(zip_file_path) as fzip:
    fzip.extractall(exec_target_dir)

# Descend into any sub directories while extracting any zip files found.
list_dirs = {}
for dirName, subdirList, fileList in os.walk(exec_target_dir):
    print('Found directory: %s' % dirName)
    for fname in fileList:
        if (fname.endswith('.zip')):
            list_dirs[dirName] = True
            print('Extracting the zip: ' + fname)
            with zipfile.ZipFile(os.path.join(dirName,fname)) as fzip:
                fzip.extractall(dirName)

# Write the exec list path file.
with open(exec_dir_path_file, 'w') as f:
    for dirName in list_dirs.keys():
        f.write(dirName + "\n")

