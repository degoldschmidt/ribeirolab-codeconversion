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
from matplotlib import rc, font_manager
import numpy as np
import scipy as sp
import scipy.signal as sg
from itertools import groupby
from helper import *

# metadata
__author__                  = "Dennis Goldschmidt"
__copyright__               = "2017"
__credits__                 = ["Dennis Goldschmidt"]
__license__                 = "GNU GENERAL PUBLIC LICENSE v3"
__version__                 = "0.1"
__maintainer__              = "Dennis Goldschmidt"
__email__                   = "dennis.goldschmidt@neuro.fchampalimaud.org"
__status__                  = "In development"

def len_iter(items):
    return sum(1 for _ in items)

def consecutive_one(data):
    return max(len_iter(run) for val, run in groupby(data) if val)

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
    # withdraw main window
    Tk().withdraw()
    # go through list of arguments and check for existing files and dirs
    files = arg2files(argv)

    # open filedialog for files
    allnoise = []
    noised = []
    outkeys = []
    askload = messagebox.askquestion("Detect noise data from files", "Do you want to open files to detect noise?", icon='warning')
    while askload == 'yes':
        if len(argv)==0:
            files = filedialog.askopenfilenames(title='Choose file/s to load')
        if len(files) == 0:
            break

        fs = 100.
        START = 0
        STOP  = 64
        STEP  = 2

        for ind, _file in enumerate(files):
            filedatetime = get_datetime(_file)
            print(filedatetime.strftime("%d %b %H:%M:%S"))
            outkeys.append(filedatetime.strftime("%d-%m %H:%M:%S"))
            N = get_data_len(_file)
            print(N)
            t = np.arange(N)/float(fs)
            this_data = get_data(_file, dur=N)
            filtered_signal = np.zeros(this_data.shape)
            sum_signal = np.zeros(t.shape)
            thr = 200
            for ch in range(START, STOP, STEP):
                if N > 1000000:
                    print(ch)
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
        break

    # plotting noise data
    if len(allnoise) == 0:
        askload = messagebox.askquestion("Load noise data", "Do you want to load noise data from file?", icon='warning')
        if askload == 'yes':
            files = filedialog.askopenfilename(title='Choose file/s to load')
            with h5.File(files, "r") as hf:
                for ind, key in enumerate(hf.keys()):
                    outkeys.append(key)
                    noised.append(hf[key].attrs["noise"])
                    allnoise.append(hf[key][:])
        else:
            return

    day=0
    countd=0
    tray = 0
    plt.ion()
    hours = []
    days = []
    for ind, noise in enumerate(allnoise):
        #if (ind == 8 or ind == 10): ## TODO: excluding certain files this is specific
        #    continue
        tray +=1
        key = outkeys[ind]
        if day == 0:
            day = int(key[0:2])
        print(key)
        secs = int(key[-2:])
        mins = int(key[-5:-3])
        hour = int(key[-8:-6])
        #print(day, int(key[0:2]), (int(key[0:2])-day))
        if len(hours) < 1 or hour == (hours[-1] + 1):
            hours.append(hour)
            days.append(countd)
        if day != int(key[0:2]):
            hours.append(hours[-1]+1)
            days.append(countd)
            hours.append(hours[-1]+1)
            days.append(countd)
            hours.append(hour)
            countd += (int(key[0:2])-day)
            days.append(countd)
            day = int(key[0:2])
        if ind == 0:
            hourzero = hour
        tstart = secs + mins*60 + (hour-hourzero)*3600 + countd*10*3600
        tend = tstart + len(noise)/100.
        time = np.linspace(tstart, tend, len(noise), endpoint=False)
        plt.plot(time, 0*noise + 2*tray, 'k-', label='signal')
        plt.xlabel('Day time', fontsize=8)
        if type(files) is str:
            plt.title('Noise analysis ' + os.path.basename(os.path.dirname(files)), fontsize=10)
        else:
            plt.title('Noise analysis ' + os.path.basename(os.path.dirname(files[0])), fontsize=10)
        if noised[ind]:
            plt.plot(time[noise==1], noise[noise==1] + 2*tray-1, 'r.', markersize=1, label='noise detected')
    hours.append(hours[-1]+1)
    days.append(countd)
    hours.append(hours[-1]+1)
    days.append(countd)
    x = hours.copy()
    for ind, lhour in enumerate(hours):
        x[ind] = 3600*(lhour-hours[0]) + days[ind]*36000

    print(hours)
    labels = ["{0:d}:00".format(lhour) for lhour in hours]
    plt.xticks(x, labels, rotation=45, fontsize=8)
    plt.yticks([],[], fontsize=0)
    plt.gca().xaxis.grid(True, linestyle='--')
    plt.draw()

    # saving plot
    asksave = messagebox.askquestion("Saving plot of noise data", "Do you want to save the plot of noise data into a png file?", icon='warning')
    if asksave == 'yes':
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
