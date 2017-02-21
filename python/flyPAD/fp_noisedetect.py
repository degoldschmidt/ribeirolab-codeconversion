#!/usr/bin/env python
"""
Script for detecting high-synchrony and -frequency noise in raw capacitance signals from flyPAD data file/s

###
Usage:

"""

# import packages
import os, sys
from tkinter import *
from tkinter import messagebox, filedialog
import json as js
import h5py as h5
from datetime import datetime as dt
import matplotlib
matplotlib.use("TkAgg")
from matplotlib import pyplot as plt
import numpy as np
import scipy as sp
import scipy.signal as sg
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
        cap_data = (cap_data.reshape(nch, int(rows/nch), order='F').copy())     # reshape array into 64-dim. matrix and take the transpose (rows = time, cols = channels)
        if np.isfinite(dur) and dur < cap_data.shape[1]:
            cap_data = cap_data[:,:dur]                                         # cut off data longer than duration
        else:
            if dur > cap_data.shape[1]:                                         # warning
                print("Warning: data shorter than given duration")
        #cap_data[cap_data==-1]=0
        return cap_data

def get_datetime(_file, printit=False):
    this_time = dt.strptime(_file[-19:], '%Y-%m-%dT%H_%M_%S')
    if printit:
        print(this_time)
    return this_time                                                            # timestamp of file

def is_binary_cap(_file):
    with open(_file, 'rb') as f:
        if b'\x00' in f.read():
            if has_timestamp(_file):                                            #### TODO: has timestamp function
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
    d["S"] = '{:06.3f}'.format(seconds + tdelta.microseconds/1000000)
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
    allnoise = []
    noised = []
    outkeys = []
    for ind, _file in enumerate(files):
        filedatetime = get_datetime(_file)
        print(filedatetime.strftime("%d %b %H:%M:%S"))
        outkeys.append(filedatetime.strftime("%d-%m %H:%M:%S"))
        this_data = get_data(_file)
        filtered_signal = np.zeros(this_data.shape)
        sum_signal = np.zeros(t.shape)
        thr = 200
        for ch in range(START, STOP, STEP):
            #print(ch)
            """ This one does the magic """
            ksize = 21
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
                noised.append(True)
            else:
                print("No noise detected.")
                noised.append(False)
        else:
            print("No noise detected.")
            noised.append(False)
        allnoise.append(thr_sum_signal)

    # saving noise data
    asksave = messagebox.askquestion("Saving noise data", "Do you want to save noise data into file?", icon='warning')
    if asksave == 'yes':
        savefile = filedialog.asksaveasfilename(title="Save datafile as...", defaultextension=".h5")
        with h5.File(savefile, "w") as hf:
            print("Writing file:", savefile)
            for ind, noise in enumerate(allnoise):
                print("Writing:", outkeys[ind])
                dset = hf.create_dataset(outkeys[ind], data=noise, compression="lzf")
                dset.attrs["noise"] = noised[ind]

    # plotting noise data
    day=0
    countd=-1
    tray = 0
    plt.ion()
    for ind, noise in enumerate(allnoise):
        if (ind == 8 or ind == 10): ## TODO: excluding certain files this is specific
            continue
        tray +=1
        print(outkeys[ind], noised[ind])
        key = outkeys[ind]
        secs = int(key[-2:])
        mins = int(key[-5:-3])
        hour = int(key[-8:-6])
        if day != int(key[0:2]):
            day = int(key[0:2])
            countd += 1
        if ind == 0:
            hourzero = hour
        tstart = secs + mins*60 + (hour-hourzero)*3600 + countd*16*3600
        tend = tstart + len(noise)/100.
        print("t0:", tstart, "t1:", tend, "len:", len(noise), "countd:", countd)
        time = np.linspace(tstart, tend, len(noise), endpoint=False)
        plt.plot(time, 0*noise + 2*tray, 'k-')
        plt.xlabel('Day time')
        if noised[ind]:
            plt.plot(time[noise==1], noise[noise==1] + 2*tray-1, 'r.')
    x = np.concatenate( (3600. * np.arange(9), 3600. * np.arange(-1,8) + 16*3600) )
    labels = ["9:00", "10:00","11:00","12:00","13:00","14:00","15:00","16:00", "17:00", "8:00", "9:00","10:00","11:00","12:00","13:00","14:00","15:00", "16:00"]
    plt.xticks(x, labels, rotation='horizontal')
    plt.draw()

    # saving plot
    asksave = messagebox.askquestion("Saving plot of noise data", "Do you want to save the plot of noise data into a png file?", icon='warning')
    if asksave:
        savefile = filedialog.asksaveasfilename(title="Save datafile as...", defaultextension=".png")
        plt.savefig(savefile, dpi=300, bbox_inches='tight')
    plt.close()

    # if no files are given
    if len(files) == 0:
        print("WARNING: No valid files specified.")

if __name__ == "__main__":
    startdt = dt.now()
    main(sys.argv[1:])
    print("Done. Runtime:", strfdelta(dt.now() - startdt, "%H:%M:%S"))
