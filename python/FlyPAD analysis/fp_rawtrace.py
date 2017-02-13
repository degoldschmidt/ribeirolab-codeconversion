#!/usr/bin/env python
"""
Script for extracting & plotting raw capacitance signals from flyPAD data file/s

###
Usage:
- rawtrace inputfile
for plotting from one specified file

- rawtrace inputfile1 inputfile2 ...
for plotting multiple specified files

- rawtrace inputdir
for plotting from all files in a specified directory

- rawtrace
opens gui filedialog for selecting files
"""

# import packages
import os, sys
from tkinter import *
from tkinter import messagebox, filedialog
import json as js
from datetime import datetime as dt
import matplotlib.pyplot as plt
import numpy as np

# metadata
__author__                  = "Dennis Goldschmidt"
__copyright__               = "2017"
__credits__                 = ["Dennis Goldschmidt"]
__license__                 = "GNU GENERAL PUBLIC LICENSE v3"
__version__                 = "0.1"
__maintainer__              = "Dennis Goldschmidt"
__email__                   = "dennis.goldschmidt@neuro.fchampalimaud.org"
__status__                  = "In development"

def arg2files(_args):
    files = []
    for arg in argv:
        if os.path.isfile(arg):
            files.append(arg)
        if os.path.isdir(arg):
            for _file in os.listdir(arg):
                if os.path.isfile(os.path.join(arg, _file)) and is_binary_cap(os.path.join(arg, _file)):
                    files.append(arg+_file)
    return files


def get_data(_file, dur=360000, nch=64):
    with open(_file, 'rb') as f:                                                # with opening
        cap_data = np.fromfile(f, dtype=np.ushort)                              # read binary data into numpy ndarray (1-dim.)
        rows = cap_data.shape[0]                                                # to shorten next line
        cap_data = (cap_data.reshape(nch, int(rows/nch), order='F').copy())           # reshape array into 64-dim. matrix and take the transpose (rows = time, cols = channels)
        if np.isfinite(dur) and dur < cap_data.shape[1]:
            cap_data = cap_data[:,:dur]                                         # cut off data longer than duration
        else:
            if dur > cap_data.shape[1]:                                         # warning
                print("Warning: data shorter than given duration")
        #cap_data[cap_data==-1]=0
        return cap_data

def get_datetime(_file):
    return dt.strptime(_file[-19:], '%Y-%m-%dT%H_%S_%M')                        # timestamp of file

def is_binary_cap(_file):
    with open(_file, 'rb') as f:
        if b'\x00' in f.read():
            if has_timestamp(_file):    #### TODO: has timestamp function
                    return True
            else:
                return False
        else:
            return False

def has_timestamp(_file, printit=False):
    try:
        this_time = dt.strptime(_file[-8:], '%H_%M_%S')
    except ValueError:
        return False
    else:
        if printit:
            print(this_time)
        return True

def main(argv):
    # colors for plotting
    color = ["#3498db", "#e74c3c"]

    # go through list of arguments and check for existing files and dirs
    files = arg2files(argv)

    # open filedialog for files
    if len(argv)==0:
        Tk().withdraw()
        files = filedialog.askopenfilenames(title='Choose file/s to load')

    for ind, _file in enumerate(files):
            this_data = get_data(_file)
            print(this_data.shape)
            fig = plt.figure(figsize=(12,2))
            for ch in range(64):
                print(ch)
                plt.plot(this_data[ch], color=color[ch%2])
            fig.set_tight_layout(True)
            fig.savefig('temp.png', dpi=900)
        
    # if no files are given
    if len(files) == 0:
        print("WARNING: No valid files specified.")

if __name__ == "__main__":
    main(sys.argv[1:])
