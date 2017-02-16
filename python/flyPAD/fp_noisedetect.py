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
import scipy as sp
import scipy.signal as sg
from scipy.signal import hilbert
from string import Template
from itertools import groupby

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
    for arg in _args:
        if os.path.isfile(arg):
            files.append(arg)
        if os.path.isdir(arg):
            for _file in os.listdir(arg):
                if os.path.isfile(os.path.join(arg, _file)) and is_binary_cap(os.path.join(arg, _file)):
                    files.append(arg+_file)
    return files

def len_iter(items):
    return sum(1 for _ in items)

def consecutive_one(data):
    return max(len_iter(run) for val, run in groupby(data) if val)

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

def get_median_filtered(signal, threshold=3):
    signal = signal.copy()
    difference = np.abs(signal - np.median(signal))
    median_difference = np.median(difference)
    if median_difference == 0:
        s = 0
    else:
        s = difference / float(median_difference)
    mask = s > threshold
    signal[mask] = np.median(signal)
    return signal

class DeltaTemplate(Template):
    delimiter = "%"

def strfdelta(tdelta, fmt):
    d = {"D": tdelta.days}
    hours, rem = divmod(tdelta.seconds, 3600)
    minutes, seconds = divmod(rem, 60)
    d["H"] = '{:02d}'.format(hours)
    d["M"] = '{:02d}'.format(minutes)
    d["S"] = '{:05.3f}'.format(seconds + tdelta.microseconds/1000000)
    t = DeltaTemplate(fmt)
    return t.substitute(**d)

def main(argv):
    # go through list of arguments and check for existing files and dirs
    files = arg2files(argv)

    # open filedialog for files
    if len(argv)==0:
        Tk().withdraw()
        files = filedialog.askopenfilenames(title='Choose file/s to load')

    fs = 100.
    N = 360000
    t = np.arange(N)/float(fs)
    START = 0
    STOP  = 64
    STEP  = 2

    for ind, _file in enumerate(files):
        print(_file)
        this_data = get_data(_file)
        filtered_signal = np.zeros(this_data.shape)
        sum_signal = np.zeros(t.shape)
        thr = 200
        for ch in range(START, STOP, STEP):
            #print(ch)
            """ This one does the magic """
            ksize = 21##501
            filtered_signal[ch+1] = sg.medfilt(this_data[ch+1], kernel_size=ksize)
            filtered_signal[ch+1] -= filtered_signal[ch+1, 0]   # baseline subtraction
        filtered_signal = np.abs(filtered_signal) # positive changes from baseline
        thr_signal = filtered_signal > thr
        sum_signal = np.sum(thr_signal, axis=0)

        ch_thr = 24
        thr_sum_signal = sum_signal > ch_thr
        min_len = 500
        if np.count_nonzero(thr_sum_signal) > 0:
            print(np.count_nonzero(thr_sum_signal), consecutive_one(thr_sum_signal))
            if(consecutive_one(thr_sum_signal) > min_len):
                print("Noise detected at", (np.nonzero(thr_sum_signal)[0])[0]/fs , "secs")
            else:
                print("No noise detected.")
        else:
            print("No noise detected.")

    # if no files are given
    if len(files) == 0:
        print("WARNING: No valid files specified.")

if __name__ == "__main__":
    startdt = dt.now()
    main(sys.argv[1:])
    print("Done. Runtime:", strfdelta(dt.now() - startdt, "%H:%M:%S"))
