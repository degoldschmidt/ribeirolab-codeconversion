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
from vispy import plot as vp
import scipy as sp
import scipy.signal as sg
from scipy.signal import hilbert
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

def main(argv):
    START = 0
    STOP  = 64
    STEP  = 2
    
    # colors for plotting
    colz = ["#C900E5", "#C603E1", "#C306DD", "#C009DA", "#BD0CD6", "#BA0FD2", "#B812CF", "#B515CB", "#B218C7", "#AF1BC4", "#AC1EC0", "#A921BD", "#A724B9", "#A427B5", "#A12AB2", "#9E2DAE", "#9B30AA", "#9833A7", "#9636A3", "#93399F", "#903C9C", "#8D3F98", "#8A4295", "#884591", "#85488D", "#824B8A", "#7F4E86", "#7C5182", "#79547F", "#77577B", "#745A77", "#715D74", "#6E6170", "#6B646D", "#686769", "#666A65", "#636D62", "#60705E", "#5D735A", "#5A7657", "#577953", "#557C4F", "#527F4C", "#4F8248", "#4C8545", "#498841", "#478B3D", "#448E3A", "#419136", "#3E9432", "#3B972F", "#389A2B", "#369D27", "#33A024", "#30A320", "#2DA61D", "#2AA919", "#27AC15", "#25AF12", "#22B20E", "#1FB50A", "#1CB807", "#19BB03", "#17BF00"]

    # go through list of arguments and check for existing files and dirs
    files = arg2files(argv)

    # open filedialog for files
    if len(argv)==0:
        Tk().withdraw()
        files = filedialog.askopenfilenames(title='Choose file/s to load')

    fs = 100.
    N = 360000
    t = np.arange(N)/float(fs)
    figs = []
    
    for ind, _file in enumerate(files):
        print(_file)
        figs.append(vp.Fig(size=(1600, 1000), show=False))
        fig = figs[-1]
        plt_even = fig[0, 0]
        plt_odd = fig[1, 0]
        plt_even._configure_2d()
        plt_odd._configure_2d()
        plt_even.xlabel.text = 'Time (s)'
        plt_odd.xlabel.text = 'Time (s)'
        plt_even.title.text = os.path.basename(_file) + " even CH"
        plt_odd.title.text = os.path.basename(_file) + " odd CH"
        this_data = get_data(_file)
        diff_data = np.zeros(t.shape)
        sum_signal = np.zeros(t.shape)
        thr = 200
        for ch in range(START, STOP, STEP):
            if ch%16==0:
                print(ch)
            """ This one does the magic """
            KSIZE = 21 ##501
            filtered_signal = sg.medfilt(this_data[ch+1], kernel_size=KSIZE)
            filtered_signal = np.abs(filtered_signal-filtered_signal[0]) # positive changes from baseline
            thr_signal = filtered_signal > thr
            sum_signal += thr_signal
            
            #plt_even.plot(np.array((t, filtered_signal)).T, marker_size=0, color=colz[ch])
            plt_even.plot(np.array((t, this_data[ch]+1000*ch)).T, marker_size=0, color=colz[ch])
            #plt_even.plot(np.array((t[thr_signal==1], 1000*thr_signal[thr_signal==1])).T, marker_size=0, color='r')
            #plt_odd.plot(np.array((t, this_data[ch+1]+1000*ch)).T, marker_size=0, color=colz[ch])
            #plt_odd.spectrogram(this_data[ch], fs=fs)
            #plt_odd.plot(np.array((t, filtered_signal)).T, marker_size=0, color=colz[ch])
            plt_odd.plot(np.array((t, this_data[ch+1]+1000*ch)).T, marker_size=0, color=colz[ch])
        ch_thr = 24
        thr_sum_signal = sum_signal > ch_thr
        if np.count_nonzero(thr_sum_signal) > 0:
            print(np.count_nonzero(thr_sum_signal), consecutive_one(thr_sum_signal))
            if(consecutive_one(thr_sum_signal) > 500):
                print("Noise detected at", (np.nonzero(thr_sum_signal)[0])[0]/fs , "secs")
            else:
                print("No noise detected.")
        else:
            print("No noise detected.")

        #plt_even.plot(np.array((t, (1000/32)*sum_signal)).T, marker_size=0, width=1, color='b')
        plt_even.plot(np.array((t, (1000)*thr_sum_signal-1000)).T, marker_size=0, width=2, color='r')
        plt_odd.plot(np.array((t, (1000)*thr_sum_signal-1000)).T, marker_size=0, width=2, color='r')
    for fig in figs:
        fig.show(run=True)
    # if no files are given
    if len(files) == 0:
        print("WARNING: No valid files specified.")

if __name__ == "__main__":
    main(sys.argv[1:])
