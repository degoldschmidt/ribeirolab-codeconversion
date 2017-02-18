#!/usr/bin/env python
"""
Script for aligning flyPAD noise time series in real-time

###
Usage:

"""

# import packages
import os, sys
from tkinter import *
from tkinter import messagebox, filedialog
import h5py as h5
from datetime import datetime as dt
import matplotlib.pyplot as plt
import numpy as np
from vispy import plot as vp
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

    # open filedialog for loading the hdf5 file
    if len(argv)==0:
        Tk().withdraw()
        files = filedialog.askopenfilename(title='Choose file/s to load')

    # open hdf5 file
    day=0
    countd=-1
    tray = 0
    with h5.File(files, "r") as hf:
        for ind, key in enumerate(hf.keys()):
            if (ind == 8 or ind == 10):
                continue
            tray +=1
            print(key, hf[key].attrs["noise"])
            secs = int(key[-2:])
            mins = int(key[-5:-3])
            hour = int(key[-8:-6])
            if day != int(key[0:2]):
                day = int(key[0:2])
                countd += 1
            if ind == 0:
                hourzero = hour
            tstart = secs + mins*60 + (hour-hourzero)*3600 + countd*16*3600
            tend = tstart + len(hf[key])/100.
            print("t0:", tstart, "t1:", tend, "len:", len(hf[key]), "countd:", countd)
            time = np.linspace(tstart, tend, len(hf[key]), endpoint=False)
            data = hf[key][:]
            plt.plot(time, data + 2*tray, 'k-')
            if hf[key].attrs["noise"]:
                plt.plot(time[data==1], data[data==1] + 2*tray, 'r.')
    plt.show()

if __name__ == "__main__":
    startdt = dt.now()
    main(sys.argv[1:])
    print("Done. Runtime:", strfdelta(dt.now() - startdt, "%H:%M:%S"))
